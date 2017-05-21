package;

import box2d.common.IViewportTransform;
import box2d.callbacks.DebugDraw;
import controllers.ApplyForce;
import controllers.SphereStack;
import controllers.BlobTest4;
import controllers.BodyTypes;
import controllers.Breakable;
import controllers.BulletTest;
import controllers.Cantilever;
import controllers.Car;
import controllers.Chain;
import controllers.CharacterCollision;
import controllers.CircleStress;
import controllers.CollisionFiltering;
import controllers.CollisionProcessing;
import controllers.CompoundShapes;
import controllers.ConfinedTest;
import controllers.ContinuousTest;
import controllers.ConvexHull;
import controllers.ConveyorBelt;
import controllers.DamBreak;
import controllers.DistanceTest;
import controllers.DominoTest;
import controllers.DominoTower;
import controllers.DrawingParticles;
import controllers.DynamicTreeTest;
import controllers.EdgeShapes;
import controllers.EdgeTest;
import controllers.FixedPendulumTest;
import controllers.FreePendulumTest;
import controllers.Gears;
import controllers.LiquidTimer;
import controllers.MotorTest;
import controllers.OneSidedTest;
import controllers.Particles;
import controllers.ParticleTypes;
import controllers.PistonTest;
import controllers.PolyShapes;
import controllers.PrismaticTest;
import controllers.Pulleys;
import controllers.PyramidTest;
import controllers.RayCastTest;
import controllers.RevoluteTest;
import controllers.RopeTest;
import controllers.SensorTest;
import controllers.ShapeEditing;
import controllers.SliderCrankTest;
import controllers.TheoJansen;
import controllers.Tumbler;
import controllers.VaryingFrictionTest;
import controllers.VaryingRestitution;
import controllers.VerticalStack;
import controllers.WaveMachine;
import controllers.Web;

import msignal.Signal;
import openfl.display.Sprite;
import haxe.ds.Vector;

class TestbedModel {

    private var tests : Array<Class<TestbedTest>>;
    private var draw : DebugDraw;
    private var test : Class<TestbedTest>;
    private var testName : String;
    private var calculatedFps : Float;
    private var currentTestIndex = -1;
    private var runningTest : TestbedTest;
    private var worldCreator : WorldCreator = new DefaultWorldCreator();
    private var container : Sprite;
    private var keys : Vector<Bool> = new Vector<Bool>(512);
    private var codedKeys : Vector<Bool> = new Vector<Bool>(512);
    public var onTestChanged : Signal2<Dynamic, Int> = new Signal2<Dynamic, Int>();

    public function new(container : Sprite) {
        this.tests = new Array<Class<TestbedTest>>();
        this.tests.push(SphereStack);           //0
        this.tests.push(ApplyForce);            //1   
        this.tests.push(BlobTest4);             //2
        this.tests.push(BodyTypes);             //3
        this.tests.push(Breakable);             //4
        this.tests.push(BulletTest);            //5
        this.tests.push(Cantilever);            //6
        this.tests.push(Car);                   //7
        this.tests.push(Chain);                 //8
        this.tests.push(CharacterCollision);    //9
        this.tests.push(CircleStress);          //10
        this.tests.push(CollisionFiltering);    //11
        this.tests.push(CollisionProcessing);   //12
        this.tests.push(CompoundShapes);        //13
        this.tests.push(ConfinedTest);          //14
        this.tests.push(ContinuousTest);        //15
        this.tests.push(ConvexHull);            //16
        this.tests.push(ConveyorBelt);          //17
        this.tests.push(DamBreak);              //18
        this.tests.push(DistanceTest);          //19
        this.tests.push(DominoTest);            //20
        this.tests.push(DominoTower);           //21
        this.tests.push(DrawingParticles);      //22 not working correctly
        this.tests.push(DynamicTreeTest);       //23 not working correctly
        this.tests.push(EdgeShapes);            //24
        this.tests.push(EdgeTest);              //25
        this.tests.push(FixedPendulumTest);     //26
        this.tests.push(FreePendulumTest);      //27
        this.tests.push(Gears);                 //28
        this.tests.push(LiquidTimer);           //29
        this.tests.push(MotorTest);             //30
        this.tests.push(OneSidedTest);          //31
        this.tests.push(Particles);             //32
        this.tests.push(ParticleTypes);         //33 not working correctly (crashes)
        this.tests.push(PistonTest);            //34
        this.tests.push(PolyShapes);            //35
        this.tests.push(PrismaticTest);         //36
        this.tests.push(Pulleys);               //37
        this.tests.push(PyramidTest);           //38
        this.tests.push(RayCastTest);           //39
        this.tests.push(RevoluteTest);          //40
        this.tests.push(RopeTest);              //41
        this.tests.push(SensorTest);            //42
        this.tests.push(ShapeEditing);          //43
        this.tests.push(SliderCrankTest);       //44
        this.tests.push(TheoJansen);            //45
        this.tests.push(Tumbler);               //46
        this.tests.push(VaryingFrictionTest);   //47
        this.tests.push(VaryingRestitution);    //48
        this.tests.push(VerticalStack);         //49
        this.tests.push(WaveMachine);           //50
        this.tests.push(Web);                   //51
        this.container = container;
    }

    public function getContainer() : Sprite {
        return container;
    }

    public function getWorldCreator() : WorldCreator {
        return worldCreator;
    }

    public function setWorldCreator(worldCreator : WorldCreator) : Void {
        this.worldCreator = worldCreator;
    }

    public function setCalculatedFps(calculatedFps : Float) : Void {
        this.calculatedFps = calculatedFps;
    } 
    
    public function getCalculatedFps() : Float {
        return this.calculatedFps;
    } 

    public function setViewportTransform(transform : IViewportTransform) : Void {
        draw.setViewportTransform(transform);
    }

    public function getDebugDraw() : DebugDraw {
        return draw;
    }
    
    public function setDebugDraw(draw : DebugDraw) : Void {
        this.draw = draw;
    }

    public function setCurrTestIndex(argCurrTestIndex : Int) : Void {
        if(argCurrTestIndex < 0 || argCurrTestIndex >= this.tests.length) {
            throw "Invalid test index";
        }
        if(currentTestIndex == argCurrTestIndex) {
            return;
        }
        currentTestIndex = argCurrTestIndex;
        var item = this.tests[argCurrTestIndex];
        this.test = item;
        this.onTestChanged.dispatch(item, currentTestIndex);
    }

    public function getCurrTest() : Class<TestbedTest> {
        return this.test;
    }

    public function getCurrTestIndex() : Int {
        return this.currentTestIndex;
    }

    public function getImplSpecificHelp() : List<String> {
        return null;
    }

    public function setRunningTest(runningTest : TestbedTest) : Void {
        this.runningTest = runningTest;
    }

    public function getRunningTest() : Dynamic {
        return this.runningTest;
    }

    public function getTestsSize() : Int {
        return this.tests.length;
    }

    public function isTestAt(argIndex : Int) : Bool {
        if(argIndex>= 0 && argIndex < this.tests.length) {
            return true;
        }
        return false;
    }

    public function getCodedKeys() : Vector<Bool> {
        return codedKeys;
    }

}