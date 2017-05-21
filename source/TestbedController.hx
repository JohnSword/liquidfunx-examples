/*******************************************************************************
 * Copyright (c) 2013, Daniel Murphy All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are permitted
 * provided that the following conditions are met: * Redistributions of source code must retain the
 * above copyright notice, this list of conditions and the following disclaimer. * Redistributions
 * in binary form must reproduce the above copyright notice, this list of conditions and the
 * following disclaimer in the documentation and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 * WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************/
package;

import openfl.events.Event;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;

import box2d.common.Vec2;

enum UpdateBehavior {
    UPDATE_CALLED;
    UPDATE_IGNORED;
}

enum MouseBehavior {
  NORMAL;
  FORCE_Y_FLIP;
}

enum QueueItemType {
  MouseDown;
  MouseMove;
  MouseUp;
  MouseDrag;
  KeyPressed;
  KeyReleased;
  LaunchBomb;
  Pause;
}

/**
 * This class contains most control logic for the testbed and the update loop. It also watches the
 * model to switch tests and populates the model with some loop statistics.
 * 
 * @author Daniel Murphy
 */
 class TestbedController {

  public static var DEFAULT_FPS : Int = 60;

  private var oldDragMouse : Vec2 = new Vec2();
  private var mouse : Vec2 = new Vec2();

  private var currTest : TestbedTest = null;
  private var nextTest : TestbedTest = null;

  private var frameCount : Int;
  private var targetFrameRate : Int;
  private var frameRate : Float = 0;
  private var animating : Bool = false;

  private var model : TestbedModel;

  private var resetPending : Bool = false;
  private var avePending : Bool = false;

  private var updateBehavior : UpdateBehavior;
  private var mouseBehavior : MouseBehavior;

  private var inputQueue : List<QueueItem>;

  private var viewportHalfHeight : Float;
  private var viewportHalfWidth : Float;
  
  private var container : Sprite;

  public static var screenDragButtonDown : Bool = false;
  public static var mouseJointButtonDown : Bool = false;

  public function new(argModel : TestbedModel, behavior : UpdateBehavior, mouseBehavior : MouseBehavior, container:Sprite) {
    this.container = container;
    model = argModel;
    inputQueue = new List<QueueItem>();
    setFrameRate(DEFAULT_FPS);
    updateBehavior = behavior;
    this.mouseBehavior = mouseBehavior;
    addListeners();
  }

private function addListeners() : Void {
    // time for our controlling
    model.onTestChanged.add(testChanged);
    container.stage.addEventListener(MouseEvent.MOUSE_DOWN, mousePressed);
    container.stage.addEventListener(MouseEvent.MOUSE_UP, mouseReleased);
    container.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
    container.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, mousePressedRight);
    container.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, mouseReleasedRight);
    container.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    container.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
}

public function testChanged(TestClass : Dynamic, index : Int) : Void {
    this.nextTest = Type.createInstance(TestClass, []);
    var draw : HxDebugDraw = cast this.model.getDebugDraw();
    draw.m_drawScale = this.nextTest.camera.getScale();
}

public function onKeyDown(e : KeyboardEvent) : Void {
  model.getCodedKeys()[e.keyCode] = true;
  currTest.keyPressed(e.keyCode);
}

public function onKeyUp(e : KeyboardEvent) : Void {
  model.getCodedKeys()[e.keyCode] = false;
}

public function mousePressed(e : MouseEvent) : Void {
    mouseJointButtonDown = true;
    var p = new Vec2(e.localX, e.localY);
    currTest.getCamera().getTransform().getScreenToWorld(p, p);
    currTest.mouseDown(p, TestbedTest.MOUSE_JOINT_BUTTON);
}

public function mouseReleased(e : MouseEvent) : Void {
    mouseJointButtonDown = false;
    var p = new Vec2(e.localX, e.localY);
    currTest.getCamera().getTransform().getScreenToWorld(p, p);
    currTest.mouseUp(p, 1);
}

public function mouseMove(e : MouseEvent) : Void {
    mouse.set(e.localX, e.localY);
    if(screenDragButtonDown) {
      var diff = oldDragMouse.sub(mouse);
      currTest.getCamera().moveWorld(diff);
      oldDragMouse.setVec(mouse);
    } else if(mouseJointButtonDown) {
      currTest.getCamera().getTransform().getScreenToWorld(mouse, mouse);
      currTest.mouseDrag(mouse, TestbedTest.MOUSE_JOINT_BUTTON);
    } else {
      // currTest.mouseMove(p);
    }
}

public function mousePressedRight(e : MouseEvent) : Void {
    screenDragButtonDown = true;
    oldDragMouse.set(e.localX, e.localY);
}

public function mouseReleasedRight(e : MouseEvent) : Void {
    screenDragButtonDown = false;
}

public function reset() : Void {
    resetPending = true;
}

public function queueLaunchBomb() : Void {
    inputQueue.add(new QueueItem());
 }

public function queuePause() : Void {
    var qi = new QueueItem();
    inputQueue.add(qi.newQ(QueueItemType.Pause));
}

public function queueMouseUp(screenPos : Vec2, button : Int) : Void {
    var qi = new QueueItem();
    inputQueue.add(qi.newQVI(QueueItemType.MouseUp, screenPos, button));
  }

public function queueMouseDown(screenPos : Vec2, button : Int) : Void {
    var qi = new QueueItem();
    inputQueue.add(qi.newQVI(QueueItemType.MouseDown, screenPos, button));
}

public function queueMouseMove(screenPos : Vec2) : Void {
    var qi = new QueueItem();
    inputQueue.add(qi.newQVI(QueueItemType.MouseMove, screenPos, 0));
}

public function queueMouseDrag(screenPos : Vec2, button : Int) : Void {
    var qi = new QueueItem();
    inputQueue.add(qi.newQVI(QueueItemType.MouseDrag, screenPos, button));
}

public function queueKeyPressed(c : String, code : Int) : Void {
    var qi = new QueueItem();
    inputQueue.add(qi.newQSI(QueueItemType.KeyPressed, c, code));
}

public function queueKeyReleased(c : String, code : Int) : Void {
    var qi = new QueueItem();
    inputQueue.add(qi.newQSI(QueueItemType.KeyReleased, c, code));
}

public function updateExtents(halfWidth : Float, halfHeight : Float) : Void {
    viewportHalfHeight = halfHeight;
    viewportHalfWidth = halfWidth;

    if (currTest != null) {
      currTest.getCamera().getTransform().setExtents(halfWidth, halfHeight);
    }
  }

private function loopInit() : Void {
    if (currTest != null) {
      currTest.init(model);
    }
  }

private function initTest(test : TestbedTest) : Void {
    test.init(model);
    test.getCamera().getTransform().setExtents(viewportHalfWidth, viewportHalfHeight);
  }

  /**
   * Called by the main run loop. If the update behavior is set to
   * {@link UpdateBehavior#UPDATE_IGNORED}, then this needs to be called manually to update the
   * input and test.
   */
public function updateTest() : Void {
    // if (resetPending) {
    //   if (currTest != null) {
    //     currTest.init(model);
    //   }
    //   resetPending = false;
    // }
    // if (currTest == null) {
    //     inputQueue.clear();
    //     return;
    // }
    // var transform : IViewportTransform = currTest.getCamera().getTransform();
    // process our input
    // while (!inputQueue.isEmpty()) {
    //   var i : QueueItem = null;
    //   if (!inputQueue.isEmpty()) {
    //     i = inputQueue.pop();
    //   }
    //   if (i == null) {
    //     continue;
    //   }
    //   var oldFlip : Bool = transform.isYFlip();
    //   if (mouseBehavior == MouseBehavior.FORCE_Y_FLIP) {
    //     transform.setYFlip(true);
    //   }
    //   currTest.getCamera().getTransform().getScreenToWorld(i.p, i.p);
    //   if (mouseBehavior == MouseBehavior.FORCE_Y_FLIP) {
    //     transform.setYFlip(oldFlip);
    //   }
    //   switch (i.type) {
    //     case KeyPressed:
    //       // if (i.c != KeyboardEvent.CHAR_UNDEFINED) {
    //       //   model.getKeys()[i.c] = true;
    //       // }
    //       // model.getCodedKeys()[i.code] = true;
    //       // currTest.keyPressed(i.c, i.code);
    //       break;
    //     case KeyReleased:
    //       // if (i.c != KeyboardEvent.CHAR_UNDEFINED) {
    //       //   model.getKeys()[i.c] = false;
    //       // }
    //       // model.getCodedKeys()[i.code] = false;
    //       // currTest.keyReleased(i.c, i.code);
    //       break;
    //     case MouseDown:
    //       currTest.mouseDown(i.p, i.button);
    //       break;
    //     case MouseMove:
    //       currTest.mouseMove(i.p);
    //       break;
    //     case MouseUp:
    //       currTest.mouseUp(i.p, i.button);
    //       break;
    //     case MouseDrag:
    //       currTest.mouseDrag(i.p, i.button);
    //       break;
    //     case LaunchBomb:
    //       currTest.lanchBomb();
    //       break;
    //     case Pause:
    //       // TestbedSettings.
    //       // model.getSettings().pause = !model.getSettings().pause;
    //       break;
    //   }
    // }

    if (currTest != null) {
      currTest.step();
    }
  }

public function setNextTest() : Void {
    var index : Int = model.getCurrTestIndex() + 1;
    index %= model.getTestsSize();

    while (!model.isTestAt(index) && index < model.getTestsSize() - 1) {
      index++;
    }
    if (model.isTestAt(index)) {
      model.setCurrTestIndex(index);
    }
  }

public function lastTest() : Void {
    var index : Int = model.getCurrTestIndex() - 1;

    while (index >= 0 && !model.isTestAt(index)) {
      if (index == 0) {
        index = model.getTestsSize() - 1;
      } else {
        index--;
      }
    }

    if (model.isTestAt(index)) {
      model.setCurrTestIndex(index);
    }
  }

public function playTest(argIndex : Int) : Void {
    if (argIndex == -1) {
      return;
    }
    while (!model.isTestAt(argIndex)) {
      if (argIndex + 1 < model.getTestsSize()) {
        argIndex++;
      } else {
        return;
      }
    }
    model.setCurrTestIndex(argIndex);
  }

public function setFrameRate(fps : Int) : Void {
    if (fps <= 0) {
      throw "Fps cannot be less than or equal to zero";
    }
    targetFrameRate = fps;
    frameRate = fps;
  }

public function getFrameRate() : Int {
    return targetFrameRate;
  }

public function getCalculatedFrameRate() : Float {
    return frameRate;
  }

public function getStartTime() : Float {
    return startTime;
  }

public function getFrameCount() : Int {
    return frameCount;
  }

public function isAnimating() : Bool {
    return animating;
  }

  public function start() : Void {
    if (isAnimating() != true) {
      startAnimator();
      loopInit();
      // var TestClass = this.model.getCurrTest();
      // this.nextTest = Type.createInstance(TestClass, []);
      if (nextTest != null) {
        initTest(nextTest);
        model.setRunningTest(nextTest);
        if (currTest != null) {
          currTest.exit();
        }
        currTest = nextTest;
        nextTest = null;

        var container : Sprite = model.getContainer();
        container.stage.addEventListener (Event.ENTER_FRAME, stepAndRender);
      }
    } else {
      trace("Animation is already animating.");
    }
  }

  public function stop() : Void {
    animating = false;
    stopAnimator();
  }

  public function startAnimator() : Void {
      animating = true;
    }

  public function stopAnimator() : Void {
      animating = false;
    }

  private var timeSpent : Float = 0;
  private var startTime : Float = 0;
  private var beforeTime : Float = 0;
  private var afterTime : Float = 0;
  private var updateTime : Float = 0;
  private var timeDiff : Float = 0;
  private var sleepTime : Float = 0;

  public function stepAndRender(e) : Void {
    var timeInSecs : Float;

    timeSpent = beforeTime - updateTime;
    if (timeSpent > 0) {
      timeInSecs = timeSpent * 1.0 / 1000000000.0;
      #if cpp
      updateTime = Sys.time();
      #else
      updateTime = Date.now().getTime();
      #end 
      frameRate = (frameRate * 0.9) + (1.0 / timeInSecs) * 0.1;
      model.setCalculatedFps(frameRate);
    } else {
      #if cpp
      updateTime = Sys.time();
      #else
      updateTime = Date.now().getTime();
      #end 
    }
    if(currTest != null && updateBehavior == UpdateBehavior.UPDATE_CALLED) {
      updateTest();
    }
    frameCount++;

    #if cpp
    afterTime = Sys.time();
    #else
    afterTime = Date.now().getTime();
    #end 

    timeDiff = afterTime - beforeTime;
    sleepTime = (1000000000 / targetFrameRate - timeDiff) / 1000000;

    #if cpp
    beforeTime = Sys.time();
    #else
    beforeTime = Date.now().getTime();
    #end 
  }

}


class QueueItem {
  public var type : QueueItemType;
  public var p : Vec2 = new Vec2();
  public var c : String;
  public var button : Int;
  public var code : Int;

  public function new() {
    type = QueueItemType.LaunchBomb;
  }

  public function newQ(t : QueueItemType) {
    type = t;
    return this;
  }

  public function newQVI(t : QueueItemType, pt : Vec2, button : Int) {
    type = t;
    p.setVec(pt);
    this.button = button;
    return this;
  }

  public function newQSI(t : QueueItemType, cr : String, cd : Int) {
    type = t;
    c = cr;
    code = cd;
    return this;
  }
}

