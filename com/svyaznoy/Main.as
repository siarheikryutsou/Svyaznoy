﻿package com.svyaznoy {		import com.flashgangsta.media.video.YoutubePlayer;	import com.flashgangsta.utils.PopupsController;	import com.flashgangsta.utils.ScreenController;	import com.svyaznoy.events.NavigationEvent;	import com.svyaznoy.modules.Voting;	import flash.display.Sprite;	import flash.events.Event;	import flash.display.StageAlign;	import flash.display.StageScaleMode;	import flash.events.MouseEvent;	import flash.system.Security;	import flash.text.TextField;	import flash.utils.Dictionary;		/**	 * ...	 * @author Sergey Krivtsov (flashgangsta@gmail.com)	 */	public class Main extends Sprite {				private var voting:Voting;		private var screenController:ScreenController = new ScreenController();		private var popupsController:PopupsController;		private var mainMenu:MainMenu;		private var userInfoSection:UserInfoSection;		private var dispatcher:Dispatcher = Dispatcher.getInstance();		private var pageClassesByEventTypes:Dictionary = new Dictionary();				/**		 * 		 */				public function Main() {						Security.allowInsecureDomain( "*" );			Security.allowDomain( "*" );						if( stage ) {				init();			} else {				addEventListener( Event.ADDED_TO_STAGE, init );			}		}				/**		 * 		 * @param	event		 */				public function init( event:Event = null ):void {			if ( event ) removeEventListener( Event.ADDED_TO_STAGE, init );			stage.scaleMode = StageScaleMode.NO_SCALE;			stage.align = StageAlign.TOP_LEFT;						// Dispathcer						pageClassesByEventTypes[ NavigationEvent.NAVIGATE_TO_INDEX ] = Index;			pageClassesByEventTypes[ NavigationEvent.NAVIGATE_TO_DEPARTURES ] = Departures;			pageClassesByEventTypes[ NavigationEvent.NAVIGATE_TO_NEWS ] = News;			pageClassesByEventTypes[ NavigationEvent.NAVIGATE_TO_LEGEND ] = Legend;			pageClassesByEventTypes[ NavigationEvent.NAVIGATE_TO_CONTESTS ] = Contests;			pageClassesByEventTypes[ NavigationEvent.NAVIGATE_TO_RESULTS ] = Results;			pageClassesByEventTypes[ NavigationEvent.NAVIGATE_TO_ABOUT ] = About;						for ( var key:String in pageClassesByEventTypes ) {				dispatcher.addEventListener( key, navigateToPage );			}						// UserInfoSection 			userInfoSection = userInfoSection_mc;						// MainMenu						mainMenu = mainMenu_mc;						// ScreenController			addChild( screenController );						screenController.x = userInfoSection.width;			screenController.addScreen( Index );						// PopupsController			popupsController = new PopupsController( stage );			/*stage.addEventListener( MouseEvent.CLICK, function( e ) :void {					if ( e.target !== stage ) return;				var popup:Popup = new Registration();				popupsController.showPopup( popup, popup.isModal );			});*/			// Voting						voting = voting_mc;			//voting.init( Voting.TYPE_CUSTOM, "Какие корабли?" );			//voting.init( Voting.TYPE_MULTI, "Какие корабли?", "Аклохома", "Вест Верджиния", "Мериленд" );			voting.init( Voting.TYPE_SINGLE, "Какой самый известный самолет на тихо-океанском театре военных действий?", "Тигр", "Зеро" );									// Youtube player			var player:YoutubePlayer = new YoutubePlayer();			addChild( player );						// Access token						/*for ( var i:int = 0; i < numChildren; i++ ) {				getChildAt( i ).visible = false;			}						var tf:TextField = new TextField();			tf.width = 1000;			tf.height = 700;			tf.x = tf.y = 10;			var token:String = stage.loaderInfo.parameters.access_token;			tf.text = token ? token : "null";			addChild( tf );*/		}					private function navigateToPage( event:NavigationEvent ):void {			var pageClass:Class;			screenController.addScreen( pageClassesByEventTypes[ event.type ] );		}			}	}