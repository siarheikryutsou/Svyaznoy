package com.svyaznoy.modules {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Sergey Krivtsov (flashgangsta@gmail.com)
	 */
	public class AnswerCustom extends Answer {
		
		static private const DEFAULT_TEXT:String = "Ваш ответ";
		static private const EMPTY_COLOR:uint = 0x999999;
		
		private var textFormatEmpty:TextFormat;
		private var textFormatFilled:TextFormat;
		
		/**
		 * 
		 */
		
		public function AnswerCustom() {
			addChildAt( hit, 0 );
			
			textFormatFilled = label.getTextFormat();
			textFormatEmpty = label.getTextFormat();
			
			textFormatEmpty.color = EMPTY_COLOR;
			
			value = DEFAULT_TEXT;
			label.setTextFormat( textFormatEmpty );
			
			label.addEventListener( FocusEvent.FOCUS_IN, onLabelInFocus );
			label.addEventListener( FocusEvent.FOCUS_OUT, onLabelFocusOut );
			label.addEventListener( MouseEvent.MOUSE_DOWN, onLabelInFocus );
			label.addEventListener( Event.CHANGE, onLabelChanged );
 		}
		
		/**
		 * 
		 */
		
		override internal function dispose():void {
			label.removeEventListener( FocusEvent.FOCUS_IN, onLabelInFocus );
			label.removeEventListener( FocusEvent.FOCUS_OUT, onLabelFocusOut );
			label.removeEventListener( MouseEvent.MOUSE_DOWN, onLabelInFocus );
			label.removeEventListener( Event.CHANGE, onLabelChanged );
			super.dispose();
		}
		
		/**
		 * 
		 * @param	event
		 */
		
		private function onLabelChanged( event:Event = null ):void {
			if( event ) event.stopImmediatePropagation();
			dispatchEvent( new Event( Event.CHANGE, true ) );
		}
		
		/**
		 * 
		 * @param	event
		 */
		
		private function onLabelFocusOut( event:FocusEvent ):void {
			if ( !label.length ) {
				value = DEFAULT_TEXT;
				label.setTextFormat( textFormatEmpty );
			}
		}
		
		/**
		 * 
		 * @param	event
		 */
		
		private function onLabelInFocus( event:Event ):void {
			if ( value !== DEFAULT_TEXT ) return;
			value = "";
			label.setTextFormat( textFormatFilled );
			onLabelChanged();
		}
		
		/**
		 * 
		 * @param	target
		 */
		
		override protected function onClick( target:MovieClip ):void {
			stage.focus = label;
		}
		
	}

}