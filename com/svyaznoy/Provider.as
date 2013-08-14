﻿package com.svyaznoy {	import com.svyaznoy.events.ProviderErrorEvent;	import com.svyaznoy.events.ProviderEvent;	import flash.events.Event;	import flash.events.EventDispatcher;	import flash.events.IOErrorEvent;	import flash.net.URLLoader;	import flash.net.URLRequest;	import flash.net.URLRequestMethod;	import flash.net.URLVariables;		/**	 * ...	 * @author Sergey Krivtsov (flashgangsta@gmail.com)	 */		[Event(name="onAbout", 					type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onDeparturesList", 		type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onEmployeeConfirmed", 		type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onEmployeeSet", 			type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onIntroData", 				type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onLegend", 				type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onLoadStart", 				type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onLoggedIn", 				type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onNewsDetail", 			type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onNewsList", 				type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onThermsOfMotivation", 	type="com.svyaznoy.events.ProviderEvent")]		public class Provider extends EventDispatcher {				static public var instance:Provider;				private const TEST_APP_ID:int = 3810635;		private const TEST_SERVER:String = "http://192.241.136.228/";		private const SERVER_ADDRESS:String = "http://es.svyaznoy.ru/";		private const API_DIRECTORY:String = "api/v1/";				private const METHOD_LOGIN:String = 					"login";		private const METHOD_SET_EMPLOYEE:String = 				"login/employee";		private const METHOD_CONFIRM_EMPLOYEE:String = 			"login/employee/confirm";		private const METHOD_DISABLE_INTRO:String = 			"me/disable-intro";		private const METHOD_GET_PAGE:String =		 			"content/pages";		private const METHOD_GET_INTRO_FOR_EMPLOYEE:String =	"content/pages/intro-employee";		private const METHOD_GET_INTRO_FOR_GUEST:String = 		"content/pages/intro";		private const METHOD_GET_NEWS:String =		 			"content/news";		private const METHOD_GET_DEPARTURE:String =		 		"departures";		private const METHOD_GET_RANDOM_GALLERIES:String =		"departures/galleries/random";		private const METHOD_GET_LAST_GALLERIES:String =		"departures/galleries/last";		private const METHOD_GET_RANDOM_VIDEOS:String =			"departures/videos/random";		private const METHOD_GET_LAST_VIDEOS:String =			"departures/videos/last";		private const METHOD_GET_SURVEYS:String =				"surveys/random";				private var apiAddress:String;		private var errors:Errors = Errors.getInstance();		private var helper:Helper = Helper.getInstance();				/**		 * 		 */				public function Provider() {			if ( !instance ) {				instance = this;			}			else throw new Error( "Provider has singletone" );		}				/**		 * 		 * @return		 */				public static function getInstance():Provider {			if ( !instance ) instance = new Provider();			return instance;		}				/**		 * 		 */				public function init():void {			apiAddress = ( helper.isDebug || helper.getAppID() === TEST_APP_ID ? TEST_SERVER : SERVER_ADDRESS ) + API_DIRECTORY;		}				/**		 * LOGIN		 */						 public function login():void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_LOGIN );			request.method = URLRequestMethod.GET;			loader.completeHandler = onLoginResponse;			loader.errorHandler = errors.loginError;			startLoad( loader, request );					}				/**		 * 		 */				private function onLoginResponse( data:Object ):void {			dispatchComplete( ProviderEvent.ON_LOGGED_IN, data );		}				/**		 * 		 * @param	code		 * @param	email		 */				public function setEmployee( code:String, email:String ):void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_SET_EMPLOYEE );			var params:URLVariables = new URLVariables();						params.barcode = code;			params.email = email;						request.method = URLRequestMethod.POST;			request.data = params;						loader.completeHandler = onSetEmployeeResponse;			loader.errorHandler = onSetEmployeeError;			startLoad( loader, request );		}				/**		 * 		 * @param	data		 */				private function onSetEmployeeError( data:Object ):void {			errors.setEmployeeError( data );			if ( data.code === 404 ) {				dispatchEvent( new ProviderErrorEvent( ProviderErrorEvent.ON_EMPLOYEE_SET_ERROR ) );			}		}				/**		 * 		 * @param	event		 */				private function onSetEmployeeResponse( data:Object ):void {			dispatchComplete( ProviderEvent.ON_EMPLOYEE_SET, data );		}				/**		 * 		 * @param	code		 */				public function confirmEmployee( code:String ):void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_CONFIRM_EMPLOYEE );			var params:URLVariables = new URLVariables();						params.code = code;						request.method = URLRequestMethod.POST;			request.data = params;						loader.completeHandler = onEmployeeConfirmed;			loader.errorHandler = onEmployeeConfirmationError;						startLoad( loader, request );		}				/**		 * 		 * @param	data		 */				private function onEmployeeConfirmationError( data:Object ):void {			errors.setEmployeeConfirmationError( data );			if ( data.code === 404 ) {				dispatchEvent( new ProviderErrorEvent( ProviderErrorEvent.ON_EMPLOYEE_CONFIRMATION_ERROR ) );			}		}				/**		 * 		 */				private function onEmployeeConfirmed( data:Object ):void {			dispatchComplete( ProviderEvent.ON_EMPLOYEE_CONFIRMED, data );		}				/**		 * 		 */				public function dispableIntro():void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_DISABLE_INTRO );						request.method = URLRequestMethod.GET;			loader.errorHandler = errors.onDisableIntroError;			startLoad( loader, request );		}				/**		 * 		 */				public function getIntro( forGuestForcibly:Boolean = false ):void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var method:String;			var request:URLRequest;						if ( helper.getUserData().employee && helper.isEmployeeMode && !forGuestForcibly ) {				method = METHOD_GET_INTRO_FOR_EMPLOYEE;			} else {				method = METHOD_GET_INTRO_FOR_GUEST;			}						request = new URLRequest( apiAddress + method );						request.method = URLRequestMethod.GET;			loader.completeHandler = onIntroData;			loader.errorHandler = errors.onIntroDataError;			startLoad( loader, request );		}				/**		 * 		 */				private function onIntroData( data:Object ):void {			dispatchComplete( ProviderEvent.ON_INTRO_DATA, data );		}				/**		 * 		 * @param	limit		 * @param	offset		 */				public function getNewsList( limit:int = 10, offset:int = 0 ):void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_NEWS );						request.method = URLRequestMethod.GET;			loader.completeHandler = onNewsList;			loader.errorHandler = errors.onNewsListError;			startLoad( loader, request );		}				/**		 * 		 */				private function onNewsList( data:Object ):void {			dispatchComplete( ProviderEvent.ON_NEWS_LIST, data );		}				/**		 * 		 * @param	id		 */				public function getNewsDetail( id:int ):void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_NEWS + "/" + id );						request.method = URLRequestMethod.GET;			loader.completeHandler = onNewsDetail;			loader.errorHandler = errors.onNewsDetailError;			startLoad( loader, request );		}				/**		 * 		 * @param	data		 */				private function onNewsDetail( data:Object ):void {			dispatchComplete( ProviderEvent.ON_NEWS_DETAIL, data );		}				/**		 * 		 */				public function getLegend():void {			getPageByName( "legenda", onLegend, errors.getLegendError );		}				/**		 * 		 * @param	data		 */				private function onLegend( data:Object ):void {			dispatchComplete( ProviderEvent.ON_LEGEND, data );		}				/**		 * 		 */				public function getAbout():void {			getPageByName( "about", onAbout, errors.getAboutError );		}				/**		 * 		 * @param	data		 */				private function onAbout( data:Object ):void {			dispatchComplete( ProviderEvent.ON_ABOUT, data );		}				/**		 * 		 */				public function getThermsOfMotivation():void {			getPageByName( "legenda-terms", onThermsOfMotivation, errors.getThermsOfMotivationError );		}				/**		 * 		 * @param	data		 */				private function onThermsOfMotivation( data:Object ):void {			dispatchComplete( ProviderEvent.ON_THERMS_OF_MOTIVATION, data );		}				/**		 * Список выездов объккт содержит параметры:			 * 	"id": "1",                "title": "Россия (Санкт-Петербург)",                "year": "2010",                "start": null,                "galleries": [],                "videos": [],                "full_title": "Россия (Санкт-Петербург) — 2010",                "image_with_path": ""						 * @param	year пустой параметр вернет все года		 * @param	fields	интересующие поля :			 * videos списки видео,			 * galleries списки фотогалерей			 * galleries.photos списки фотографий		 */				public function getDeparturesList( year:String = null, fields:String = "galleries,videos,galleries.photos" ):void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_DEPARTURE );			var params:URLVariables = new URLVariables();						params.load = fields;			if ( year ) params[ "filter[]" ] = "year:" + year;						request.method = URLRequestMethod.GET;			request.data = params;						loader.errorHandler = errors.onDeparturesListError;			loader.completeHandler = onDeparturesList;			startLoad( loader, request );		}				/**		 * 		 * @param	data		 */				private function onDeparturesList( data:Object ):void {			dispatchComplete( ProviderEvent.ON_DEPARTURES_LIST, data );		}				/**		 * 		 * @param	id		 * @param	fields	интересующие поля :			 * videos списки видео,			 * galleries списки фотогалерей			 * galleries.photos списки фотографий		 */				public function getDeparture( id:int, fields:String = "galleries,videos,galleries.photos" ):void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_DEPARTURE + "/" + id );			var params:URLVariables;						if ( fields ) {				params = new URLVariables();				params.load = fields;				request.data = params;			}						request.method = URLRequestMethod.GET;						loader.errorHandler = errors.onDepartureError;			loader.completeHandler = onDeparture;			startLoad( loader, request );		}				/**		 * 		 * @param	data		 */				private function onDeparture( data:Object ):void {			dispatchComplete( ProviderEvent.ON_DEPARTURE, data );		}				/**		 * 		 */				public function getRandomGalleries( quantity:int = 1 ):void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_RANDOM_GALLERIES + "/" + quantity );			request.method = URLRequestMethod.GET;						loader.errorHandler = errors.onRandomGalleriesError;			loader.completeHandler = onRandomGalleries;			startLoad( loader, request );		}				/**		 * 		 * @param	data		 */				private function onRandomGalleries( data:Object ):void {			dispatchComplete( ProviderEvent.ON_RANDOM_GALLERIES, data );		}				/**		 * 		 */				public function getRandomVideos( quantity:int = 1 ):void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_RANDOM_VIDEOS + "/" + quantity );			request.method = URLRequestMethod.GET;						loader.errorHandler = errors.onRandomVideosError;			loader.completeHandler = onRandomVideos;			startLoad( loader, request );		}				/**		 * 		 * @param	data		 */				private function onRandomVideos( data:Object ):void {			dispatchComplete( ProviderEvent.ON_RANDOM_VIDEOS, data );		}				/**		 * 		 */				public function getLastGalleries( quantity:int = 1 ):void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_LAST_GALLERIES + "/" + quantity );			request.method = URLRequestMethod.GET;						loader.errorHandler = errors.onLastGalleriesError;			loader.completeHandler = onLastGalleries;			startLoad( loader, request );		}				/**		 * 		 * @param	data		 */				private function onLastGalleries( data:Object ):void {			dispatchComplete( ProviderEvent.ON_LAST_GALLERIES, data );		}				/**		 * 		 */				public function getLastVideos( quantity:int = 1 ):void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_LAST_VIDEOS + "/" +  quantity );			request.method = URLRequestMethod.GET;						loader.errorHandler = errors.onLastVideosError;			loader.completeHandler = onLastVideos;			startLoad( loader, request );		}				/**		 * 		 * @param	data		 */				private function onLastVideos( data:Object ):void {			dispatchComplete( ProviderEvent.ON_LAST_VIDEOS, data );		}				/**		 * 		 * @param	id		 */				public function getVideoReportByID( id:int ):void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_DEPARTURE + "/" + id );			var params:URLVariables = new URLVariables();						params.load = "videos";						request.method = URLRequestMethod.GET;			request.data = params;						loader.errorHandler = errors.onGetDepartureError;			loader.completeHandler = onVideoReport;			startLoad( loader, request );		}				/**		 * 		 */				private function onVideoReport( data:Object ):void {			dispatchComplete( ProviderEvent.ON_VIDEO_REPORT, data );		}				/**		 * 		 * @param	departure_id		 * @param	gallery_id		 * @param	fields		 */				public function getGalleryPhotos( departure_id:int, gallery_id:int ):void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_DEPARTURE + "/" + departure_id + "/galleries/" + gallery_id );			var params:URLVariables = new URLVariables();						params.load = "photos";						request.method = URLRequestMethod.GET;			request.data = params;						loader.errorHandler = errors.onGetGalleryPhotosError;			loader.completeHandler = onGalleryPhotos;			startLoad( loader, request );		}				/**		 * 		 * @param	data		 */				private function onGalleryPhotos( data:Object ):void {			dispatchComplete( ProviderEvent.ON_GALLERY_PHOTOS, data );		}				public function getRandomSurveys( quantity:int = 1 ):void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_SURVEYS + "/" + quantity );						request.method = URLRequestMethod.GET;			loader.errorHandler = errors.onGetRandomSurveysError;			loader.completeHandler = onRandomSurveys;			startLoad( loader, request );		}				/**		 * 		 * @param	data		 */				private function onRandomSurveys( data:Object ):void {			dispatchComplete( ProviderEvent.ON_RANDOM_SURVEYS, data );		}				/**		 * 		 * @param	name		 */				private function getPageByName( name:String, completeHandler:Function, errorHandler:Function ):void {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_PAGE + "/" + name );			request.method = URLRequestMethod.GET;			loader.errorHandler = errorHandler;			loader.completeHandler = completeHandler;			startLoad( loader, request );		}				/**		 * 		 * @param	loader		 * @param	request		 */				private function startLoad( loader:ProviderURLLoader, request:URLRequest ):void {			loader.load( request );			dispatchEvent( new ProviderEvent( ProviderEvent.ON_LOAD_START ) );		}				/**		 * 		 * @param	eventType		 * @param	data		 */				private function dispatchComplete( eventType:String, data ):void {			var event:ProviderEvent = new ProviderEvent( eventType );			event.data = data;			dispatchEvent( event );		}	}}