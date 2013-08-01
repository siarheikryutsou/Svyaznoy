package com.svyaznoy {
	import com.svyaznoy.events.ProviderEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Sergey Krivtsov (flashgangsta@gmail.com)
	 */
	public class Departures extends Screen {
		
		private const YEAR_FROM:int = 	2010;
		private const YEAR_TO:int = 	2013;
		
		private var currentMap:Map;
		private var worldMap:Sprite;
		private var grid:Sprite;
		private var yearsButtons:YearButtons;
		
		/**
		 * 
		 */
		
		public function Departures() {
			worldMap = getChildByName( "worldMap_mc" ) as Sprite;
			yearsButtons = getChildByName( "yearButtons_mc" ) as YearButtons;
			grid = getChildByName( "grid_mc" ) as Sprite;
			
			yearsButtons.setButtons( YEAR_FROM, YEAR_TO );
			yearsButtons.addEventListener( Event.CHANGE, onYearChanged );
			
			setVisible( false );
			
			provider.getDepartures( yearsButtons.getSelectedYear() );
			provider.addEventListener( ProviderEvent.ON_DEPARTURES, onData );
		}
		
		/**
		 * 
		 * @param	event
		 */
		
		override protected function onData( event:ProviderEvent ):void {
			super.onData( event );
			displayData();
		}
		
		/**
		 * 
		 */
		
		override protected function displayData():void {
			super.displayData();
			setVisible( true );
		}
		
		/**
		 * 
		 * @param	event
		 */
		
		private function onYearChanged( event:Event ):void {
			trace( yearsButtons.getSelectedYear() );
		}
		
		/**
		 * 
		 * @param	value
		 */
		
		private function setVisible( value:Boolean ):void {
			yearsButtons.visible = value;
			worldMap.visible = value;
			grid.visible = value;
		}
		
	}

}