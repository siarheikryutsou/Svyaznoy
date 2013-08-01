﻿package com.svyaznoy {		import caurina.transitions.Tweener;	import com.flashgangsta.media.video.YoutubePlayer;	import com.flashgangsta.net.ContentLoader;	import com.flashgangsta.ui.Scrollbar;	import com.flashgangsta.utils.PopupsController;	import com.flashgangsta.utils.ScreenController;	import com.svyaznoy.events.NavigationEvent;	import com.svyaznoy.events.NewsEvent;	import com.svyaznoy.events.ScreenEvent;	import com.svyaznoy.modules.Voting;	import flash.display.MovieClip;	import flash.display.Shape;	import flash.display.Sprite;	import flash.events.Event;	import flash.display.StageAlign;	import flash.display.StageScaleMode;	import flash.events.MouseEvent;	import flash.system.Security;	import flash.text.TextField;	import flash.text.TextFieldAutoSize;	import flash.utils.Dictionary;	import flashx.textLayout.elements.BackgroundManager;		/**	 * ...	 * @author Sergey Krivtsov (flashgangsta@gmail.com)	 */	public class Main extends Sprite {				private var screenController:ScreenController = new ScreenController();		private var popupsController:PopupsController;		private var mainMenu:MainMenu;		private var userInfoSection:UserInfoSection;		private var dispatcher:Dispatcher = Dispatcher.getInstance();		private var pageClassesByEventTypes:Dictionary = new Dictionary();		private var helper:Helper = Helper.getInstance();		private var scrollbarView:ScrollbarView;		private var scrollContent:MovieClip = new MovieClip();		private var scrollMask:Shape = new Shape();		private var loginSection:LoginSection;				/**		 * 		 */				public function Main() {			Security.allowInsecureDomain( "*" );			Security.allowDomain( "*" );						if( stage ) {				init();			} else {				addEventListener( Event.ADDED_TO_STAGE, init );			}		}				/**		 * 		 * @param	event		 */				public function init( event:Event = null ):void {			if ( event ) removeEventListener( Event.ADDED_TO_STAGE, init );			stage.scaleMode = StageScaleMode.NO_SCALE;			stage.align = StageAlign.TOP_LEFT;						//Helper			helper.isDebug = ( loaderInfo.url.indexOf( "http" ) !== 0 );			ContentLoader.context = helper.loaderContext;						// VK API			if ( !helper.isDebug ) {				helper.setFlashvars( loaderInfo.parameters );				helper.createVkAPI();			}						// Dispathcer						pageClassesByEventTypes[ NavigationEvent.NAVIGATE_TO_DEPARTURES ] = Departures;			pageClassesByEventTypes[ NavigationEvent.NAVIGATE_TO_NEWS ] = News;			pageClassesByEventTypes[ NavigationEvent.NAVIGATE_TO_LEGEND ] = Legend;			pageClassesByEventTypes[ NavigationEvent.NAVIGATE_TO_ABOUT ] = About;			pageClassesByEventTypes[ NavigationEvent.NAVIGATE_TO_THERMS_OF_MOTIVATION ] = ThermsOfMotivation;						for ( var key:String in pageClassesByEventTypes ) {				dispatcher.addEventListener( key, navigateToPage );			}						dispatcher.addEventListener( NewsEvent.DETAILED_CLICKED, onNewsDetailesClicked );			dispatcher.addEventListener( NewsEvent.NEWS_BACK_TO_LIST_CLICKED, onNewsBackToListClicked );						// Scrollbar						scrollbarView = getChildByName( "scrollbarView_mc" ) as ScrollbarView;			scrollbarView.visible = false;						// UserInfoSection 			userInfoSection = userInfoSection_mc;			userInfoSection.showUser();			userInfoSection.visible = false;						// MainMenu						mainMenu = mainMenu_mc;			mainMenu.visible = false;						// ScreenController			addChildAt( scrollContent, 0 );			scrollContent.addChild( screenController );						scrollContent.x = userInfoSection.width + 20;			scrollContent.y = scrollbarView.y;			screenController.width = 515;			screenController.height = scrollbarView.height;			//screenController.addScreen( Departures );						scrollMask.y = scrollContent.y;			scrollMask.graphics.beginFill( 0 );			scrollMask.graphics.drawRect( 0, 0, stage.stageWidth, scrollbarView.height );			scrollMask.graphics.endFill();			scrollContent.mask = scrollMask;			screenController.addEventListener( ScreenEvent.HEIGHT_UPDATED, onContentHeightUpdated );			screenController.addEventListener( Event.CHANGE, onScreenChanged );			screenController.visible = false;						Scrollbar.setVertical( scrollContent, scrollMask.getBounds( this ), scrollbarView.getUpBtn(), scrollbarView.getDownBtn(), scrollbarView.getCarret(), scrollbarView.getBounds( scrollbarView ), stage );						// PopupsController			popupsController = PopupsController.getInstance();			popupsController.init( stage );						// Login section			loginSection = getChildByName( "login_mc" ) as LoginSection;			addChild( loginSection );			loginSection.startProcedure();			loginSection.addEventListener( Event.COMPLETE, onLoginSectionComplete );						// Voting			/*var voting:Voting = new Voting();			//voting.init( Voting.TYPE_CUSTOM, "Какие корабли?" );			//voting.init( Voting.TYPE_MULTI, "Какие корабли?", "Аклохома", "Вест Верджиния", "Мериленд" );			voting.init( Voting.TYPE_SINGLE, "Какой самый известный самолет на тихо-океанском театре военных действий?", "Тигр", "Зеро" );			addChild( voting );*/									// Youtube player			/*var player:YoutubePlayer = new YoutubePlayer();			player.x = 235;			player.y = 42;			addChild( player );*/						// Access token			var tf:TextField = new TextField();			tf.autoSize = TextFieldAutoSize.LEFT;			tf.y = 670;			var message:String = stage.loaderInfo.parameters.auth_key;			tf.text = message ? message : "null";			message = stage.loaderInfo.parameters.viewer_id;			tf.appendText( "\n" + ( message ? message : "null" ) ); 			addChild( tf );		}					/**		 * 		 * @param	event		 */				private function onNewsDetailesClicked( event:NewsEvent ):void {			var news:NewsDetail;			screenController.addScreen( NewsDetail );			news = screenController.getCurrentScreenInstance() as NewsDetail;			news.showNews( event.newsID );		}				/**		 * 		 * @param	event		 */				private function onNewsBackToListClicked( event:NewsEvent ):void {			screenController.addScreen( News );		}				/**		 * 		 * @param	event		 */				private function onLoginSectionComplete( event:Event ):void {			var motionParams:Object = { x: 0, time: .4, transition: "easeOutCubic" };			mainMenu.visible = true;			mainMenu.x = -mainMenu.width;			userInfoSection.visible = true;			userInfoSection.x = mainMenu.x;						Tweener.addTween( mainMenu, motionParams );			Tweener.addTween( userInfoSection, motionParams );			screenController.visible = true;			screenController.addScreen( Departures );						userInfoSection.visible = true;		}				/**		 * 		 * @param	event		 */				private function onScreenChanged( event:Event ):void {			Scrollbar.reset( scrollbarView.getCarret() );			onContentHeightUpdated();		}				/**		 * 		 * @param	event		 */				private function onContentHeightUpdated( event:ScreenEvent = null ):void {			if( event ) event.stopImmediatePropagation();			Scrollbar.update( scrollbarView.getCarret() );			scrollbarView.visible = Scrollbar.isNeeded( scrollbarView.getCarret() );		}				/**		 * 		 * @param	event		 */				private function navigateToPage( event:NavigationEvent ):void {			var pageClass:Class;			screenController.addScreen( pageClassesByEventTypes[ event.type ] );			trace( screenController.getCurrentScreenInstance() );		}			}	}