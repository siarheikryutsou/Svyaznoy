package com.svyaznoy {
	import com.flashgangsta.utils.PopupsController;
	import com.flashgangsta.utils.ScreenController;
	import com.svyaznoy.events.ProviderEvent;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import fl.containers.UILoader;
	
	/**
	 * ...
	 * @author Sergey Krivtsov (flashgangsta@gmail.com)
	 */
	public class TestTests extends Sprite {
		
		private var screenController:ScreenController = new ScreenController();
		private var provider:Provider = Provider.getInstance();
		private var helper:Helper = Helper.getInstance();
		private var questions:Array;
		private var answers:Array = [];
		private var data:Object;
		private var list:Array;
		private var popupsController:PopupsController;
		
		/**
		 * 
		 */
		
		public function TestTests() {
			addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		/**
		 * 
		 * @param	event
		 */
		
		private function init( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, init );
			
			//Helper
			helper.isDebug = true;
			helper.isEmployeeMode = true;
			//Provider
			provider.init();
			// PopupsController
			popupsController = PopupsController.getInstance();
			popupsController.init( stage, 0x2b2927, .85 );
			
			provider.login();
			provider.addEventListener( ProviderEvent.ON_LOGGED_IN, onLoggedIn );
			
			
			
		}
		
		private function onLoggedIn( event:ProviderEvent ):void {
			var loader:ProviderURLLoader = provider.getTestsList();
			loader.addEventListener( ProviderEvent.ON_TESTS_LIST, onTestsList );
		}
		
		/**
		 * 
		 * @param	event
		 */
		
		private function onTestsList( event:ProviderEvent ):void {
			list = event.data as Array;
			for ( var i:int = 0; i < list.length; i++ ) {
				var btn:MovieClip = new Btn();
				btn.y = 20 + (29 * i);
				btn.btn_mc.label = "Тест " + i;
				btn.btn_mc.enabled = !list[ i ].is_answered;
				btn.btn_mc.addEventListener( MouseEvent.CLICK, onSelect );
				addChild( btn );
			}
			
		}
		
		private function onSelect( event:MouseEvent ):void {
			var popup:TestPopup = new TestPopup( list[ getChildIndex( event.target.parent as DisplayObject ) ].id );
			popupsController.showPopup( popup, true );
			/*var loader:ProviderURLLoader =  provider.getTestByID( list[ getChildIndex( event.target.parent as DisplayObject ) ].id );
			loader.addEventListener( ProviderEvent.ON_TEST, onTest );*/
		}
		
		private function onTest( event:ProviderEvent ):void {
			data = event.data;
			var preview:MovieClip = new Preview();
			questions = data.questions;
			preview.title_txt.text = data.title;
			preview.label_txt.text = data.content;
			UILoader( preview.loader_mc ).source = data.image_with_path;
			preview.button_mc.addEventListener( MouseEvent.CLICK, onStartClicked );
			addChild( preview );
		}
		
		private function onStartClicked( event:MouseEvent ):void {
			trace( "test begin" );
			showQuestion( );
		}
		
		private function showQuestion():void {
			var data:Object = questions[ answers.length ];
			var question:MovieClip = new Question();
			var d:DynamicContentViewer = new DynamicContentViewer();
			removeChildren();
			question.title_txt.text = data.title;
			d.displayData( data.content );
			d.x = question.title_txt.x;
			d.y = question.title_txt.height;
			question.addChild( d );
			
			question.a_mc.label = "A) " + data.answer1;
			question.b_mc.label = "B) " + data.answer2;
			question.c_mc.label = "C) " + data.answer3;
			question.d_mc.label = "D) " + data.answer4;
			
			var onAnswer:Function = function( event:MouseEvent ):void {
				var label:String = event.target.label;
				answers.push( data.id + ":" + label.substr( 3 ) );
				
				event.target.removeEventListener( MouseEvent.CLICK, arguments.callee );
				
				if ( answers.length === questions.length ) {
					showResults();
				} else {
					showQuestion();
				}
			}
			
			question.a_mc.addEventListener( MouseEvent.CLICK, onAnswer );
			question.b_mc.addEventListener( MouseEvent.CLICK, onAnswer );
			question.b_mc.addEventListener( MouseEvent.CLICK, onAnswer );
			question.c_mc.addEventListener( MouseEvent.CLICK, onAnswer );
			
			addChild( question );
		}
		
		private function showResults():void {
			var loader:ProviderURLLoader = provider.sendTestResults( data.id, answers.toString() );
			loader.addEventListener( ProviderEvent.ON_TEST_RESULT_SENT, onResultsSent );
			removeChildren();
			
			
		}
		
		private function onResultsSent( event:ProviderEvent ):void {
			trace( JSON.stringify( event.data ) );
			
			var results:MovieClip = new Results();
			var resultData:Object = event.data;
			results.label_txt.text = "Вы ответили правильно на " + resultData.correct_answers + " из " + questions.length + "\n\n" + resultData.test.ending + "\n\n" + "Ваша награда:\n" + event.data.received_points;
			addChild( results );
		}
	}

}