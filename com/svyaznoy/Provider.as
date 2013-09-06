﻿package com.svyaznoy {	import com.svyaznoy.events.ProviderErrorEvent;	import com.svyaznoy.events.ProviderEvent;	import flash.events.Event;	import flash.events.EventDispatcher;	import flash.events.IOErrorEvent;	import flash.events.ProgressEvent;	import flash.net.URLLoader;	import flash.net.URLRequest;	import flash.net.URLRequestMethod;	import flash.net.URLVariables;	import flash.utils.ByteArray;	import ru.inspirit.net.events.MultipartURLLoaderEvent;	import ru.inspirit.net.MultipartURLLoader;		/**	 * ...	 * @author Sergey Krivtsov (flashgangsta@gmail.com)	 */		[Event(name="onAbout", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onDeparture", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onDeparturesList", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onEmployeeConfirmed", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onEmployeeSet", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onGalleryPhotos", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onIntroData", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onLastGalleries", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onLastVideos", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onLegend", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onLoadStart", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onLoggedIn", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onLotteries", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onLottery", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onNewsDetail", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onNewsList", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onRandomGalleries", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onRandomSurveys", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onRandomVideos", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onThermsOfMotivation", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onVideoReport", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onRatings", type="com.svyaznoy.events.ProviderEvent")]	[Event(name="onEmployeesLength", type="com.svyaznoy.events.ProviderEvent")]		public class Provider extends EventDispatcher {		static public var instance:Provider;				private const TEST_APP_ID:int = 3810635;		private const TEST_SERVER:String = "http://192.241.136.228/";		private const SERVER_ADDRESS:String = "http://es.svyaznoy.ru/";		private const API_DIRECTORY:String = "api/v1/";				private const METHOD_LOGIN:String = 					"login";		private const METHOD_SET_EMPLOYEE:String = 				"login/employee";		private const METHOD_CONFIRM_EMPLOYEE:String = 			"login/employee/confirm";		private const METHOD_DISABLE_INTRO:String = 			"me/disable-intro";		private const METHOD_GET_PAGE:String =		 			"content/pages";		private const METHOD_GET_INTRO_FOR_EMPLOYEE:String =	"content/pages/intro-employee";		private const METHOD_GET_INTRO_FOR_GUEST:String = 		"content/pages/intro";		private const METHOD_GET_NEWS:String =		 			"content/news";		private const METHOD_GET_DEPARTURE:String =		 		"departures";		private const METHOD_GET_RANDOM_GALLERIES:String =		"departures/galleries/random";		private const METHOD_GET_LAST_GALLERIES:String =		"departures/galleries/last";		private const METHOD_GET_RANDOM_VIDEOS:String =			"departures/videos/random";		private const METHOD_GET_LAST_VIDEOS:String =			"departures/videos/last";		private const METHOD_GET_SURVEYS:String =				"surveys/random";		private const METHOD_GET_LOTTERY:String = 				"lotteries";		private const METHOD_GET_EMPLOYEE:String = 				"employees";		private const METHOD_GET_RATINGS:String = 				"employees/rating";		private const METHOD_GET_EMPLOEES_LENGTH:String = 		"employees/count";		private const METHOD_GET_OWNER_RATING:String = 			"me/rating";		private const METHOD_SEND_ANSWER:String = 				"surveys";		private const METHOD_GET_ANSWERS:String = 				"surveys";		private const METHOD_GET_OWNER_ALBUMS:String = 			"me/photos";		private const METHOD_UPLOAD_PHOTO:String = 				"me/photos";		private const METHOD_UPDATE_PHOTO:String = 				"me/photo-update";		private const METHOD_DELETE_PHOTO:String = 				"me/photo-delete";		private const METHOD_GET_EMPLOYEES_PHOTOS:String = 		"employees-photos";				private var apiAddress:String;		private var errors:Errors = Errors.getInstance();		private var helper:Helper = Helper.getInstance();				/**		 * 		 */				public function Provider() {			if ( !instance ) {				instance = this;			}			else throw new Error( "Provider has singletone" );		}				/**		 * 		 * @return		 */				public static function getInstance():Provider {			if ( !instance ) instance = new Provider();			return instance;		}				/**		 * 		 */				public function init():void {			apiAddress = ( helper.isDebug || helper.getAppID() === TEST_APP_ID ? TEST_SERVER : SERVER_ADDRESS ) + API_DIRECTORY;		}				/**		 * LOGIN		 */						public function login():ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_LOGIN );			loader.completeHandler = onLoginResponse;			loader.errorHandler = errors.loginError;			return startLoad( loader, request );					}				/**		 * 		 */				private function onLoginResponse( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_LOGGED_IN, data, loader );		}				/**		 * 		 * @param	code		 * @param	email		 */				public function setEmployee( code:String, email:String ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_SET_EMPLOYEE );			var params:URLVariables = new URLVariables();						params.barcode = code;			params.email = email;						request.method = URLRequestMethod.POST;			request.data = params;						loader.completeHandler = onSetEmployeeResponse;			loader.errorHandler = onSetEmployeeError;			return startLoad( loader, request );		}				private function onSetEmployeeError( data:Object ):void {			errors.setEmployeeError( data );			if ( data.code === 404 ) {				dispatchEvent( new ProviderErrorEvent( ProviderErrorEvent.ON_EMPLOYEE_SET_ERROR ) );			}		}				private function onSetEmployeeResponse( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_EMPLOYEE_SET, data, loader );		}				/**		 * 		 * @param	code		 */				public function confirmEmployee( code:String ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_CONFIRM_EMPLOYEE );			var params:URLVariables = new URLVariables();						params.code = code;						request.method = URLRequestMethod.POST;			request.data = params;						loader.completeHandler = onEmployeeConfirmed;			loader.errorHandler = onEmployeeConfirmationError;						return startLoad( loader, request );		}				private function onEmployeeConfirmationError( data:Object ):void {			errors.setEmployeeConfirmationError( data );			if ( data.code === 404 ) {				dispatchEvent( new ProviderErrorEvent( ProviderErrorEvent.ON_EMPLOYEE_CONFIRMATION_ERROR ) );			}		}				private function onEmployeeConfirmed( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_EMPLOYEE_CONFIRMED, data, loader );		}				/**		 * 		 */				public function dispableIntro():ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_DISABLE_INTRO );						loader.errorHandler = errors.onDisableIntroError;			return startLoad( loader, request );		}				/**		 * 		 */				public function getIntro( forGuestForcibly:Boolean = false ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var method:String;			var request:URLRequest;						if ( helper.getUserData().employee && helper.isEmployeeMode && !forGuestForcibly ) {				method = METHOD_GET_INTRO_FOR_EMPLOYEE;			} else {				method = METHOD_GET_INTRO_FOR_GUEST;			}						request = new URLRequest( apiAddress + method );						loader.completeHandler = onIntroData;			loader.errorHandler = errors.onIntroDataError;			return startLoad( loader, request );		}				private function onIntroData( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_INTRO_DATA, data, loader );		}				/**		 * 		 * @param	limit		 * @param	offset		 */				public function getNewsList( limit:int = 10, offset:int = 0 ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_NEWS );						loader.completeHandler = onNewsList;			loader.errorHandler = errors.onNewsListError;			return startLoad( loader, request );		}				private function onNewsList( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_NEWS_LIST, data, loader );		}				/**		 * 		 * @param	id		 */				public function getNewsDetail( id:int ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_NEWS + "/" + id );						loader.completeHandler = onNewsDetail;			loader.errorHandler = errors.onNewsDetailError;			return startLoad( loader, request );		}				private function onNewsDetail( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_NEWS_DETAIL, data, loader );		}				/**		 * 		 */				public function getLegend():ProviderURLLoader {			return getPageByName( "legenda", onLegend, errors.getLegendError );		}				private function onLegend( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_LEGEND, data, loader );		}				/**		 * 		 */				public function getAbout():ProviderURLLoader {			return getPageByName( "about", onAbout, errors.getAboutError );		}				private function onAbout( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_ABOUT, data, loader );		}				/**		 * 		 */				public function getThermsOfMotivation():ProviderURLLoader {			return getPageByName( "legenda-terms", onThermsOfMotivation, errors.getThermsOfMotivationError );		}				private function onThermsOfMotivation( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_THERMS_OF_MOTIVATION, data, loader );		}				/**		 * Список выездов объккт содержит параметры:			 * 	"id": "1",                "title": "Россия (Санкт-Петербург)",                "year": "2010",                "start": null,                "galleries": [],                "videos": [],                "full_title": "Россия (Санкт-Петербург) — 2010",                "image_with_path": ""						 * @param	year пустой параметр вернет все года		 * @param	fields	интересующие поля :			 * videos списки видео,			 * galleries списки фотогалерей			 * galleries.photos списки фотографий		 */				public function getDeparturesList( year:String = null, fields:String = "galleries,videos,galleries.photos" ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_DEPARTURE );			var params:URLVariables = new URLVariables();						if( fields ) params.load = fields;			if ( year ) params[ "filter[]" ] = "year:" + year;						request.data = params;						loader.errorHandler = errors.onDeparturesListError;			loader.completeHandler = onDeparturesList;			return startLoad( loader, request );		}				private function onDeparturesList( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_DEPARTURES_LIST, data, loader );		}				/**		 * 		 * @param	id		 * @param	fields	интересующие поля :			 * videos списки видео,			 * galleries списки фотогалерей			 * galleries.photos списки фотографий		 */				public function getDeparture( id:int, fields:String = "galleries,videos,galleries.photos" ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_DEPARTURE + "/" + id );			var params:URLVariables;						if ( fields ) {				params = new URLVariables();				params.load = fields;				request.data = params;			}									loader.errorHandler = errors.onDepartureError;			loader.completeHandler = onDeparture;			return startLoad( loader, request );		}				private function onDeparture( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_DEPARTURE, data, loader );		}				/**		 * 		 */				public function getRandomGalleries( quantity:int = 1 ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_RANDOM_GALLERIES + "/" + quantity );						loader.errorHandler = errors.onRandomGalleriesError;			loader.completeHandler = onRandomGalleries;			return startLoad( loader, request );		}				private function onRandomGalleries( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_RANDOM_GALLERIES, data, loader );		}				/**		 * 		 */				public function getRandomVideos( quantity:int = 1 ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_RANDOM_VIDEOS + "/" + quantity );						loader.errorHandler = errors.onRandomVideosError;			loader.completeHandler = onRandomVideos;			return startLoad( loader, request );		}				private function onRandomVideos( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_RANDOM_VIDEOS, data, loader );		}				/**		 * 		 */				public function getLastGalleries( quantity:int = 1 ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_LAST_GALLERIES + "/" + quantity );						loader.errorHandler = errors.onLastGalleriesError;			loader.completeHandler = onLastGalleries;			return startLoad( loader, request );		}				private function onLastGalleries( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_LAST_GALLERIES, data, loader );		}				/**		 * 		 */				public function getLastVideos( quantity:int = 1 ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_LAST_VIDEOS + "/" +  quantity );						loader.errorHandler = errors.onLastVideosError;			loader.completeHandler = onLastVideos;			return startLoad( loader, request );		}				private function onLastVideos( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_LAST_VIDEOS, data, loader );		}				/**		 * 		 * @param	id		 */				public function getVideoReportByID( id:int ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_DEPARTURE + "/" + id );			var params:URLVariables = new URLVariables();						params.load = "videos";						request.data = params;						loader.errorHandler = errors.onGetDepartureError;			loader.completeHandler = onVideoReport;			return startLoad( loader, request );		}				private function onVideoReport( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_VIDEO_REPORT, data, loader );		}				/**		 * 		 * @param	departure_id		 * @param	gallery_id		 * @param	fields		 */				public function getGalleryPhotos( departure_id:int, gallery_id:int ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_DEPARTURE + "/" + departure_id + "/galleries/" + gallery_id );			var params:URLVariables = new URLVariables();						params.load = "photos";						request.data = params;						loader.errorHandler = errors.onGetGalleryPhotosError;			loader.completeHandler = onGalleryPhotos;			return startLoad( loader, request );		}				private function onGalleryPhotos( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_GALLERY_PHOTOS, data, loader );		}				/**		 * 		 * @param	quantity		 */				public function getRandomSurveys( quantity:int = 1 ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_SURVEYS + "/" + quantity );						loader.errorHandler = errors.onGetRandomSurveysError;			loader.completeHandler = onRandomSurveys;			return startLoad( loader, request );		}				private function onRandomSurveys( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_RANDOM_SURVEYS, data, loader );		}				/**		 * 		 * @param	object		 * @param	answer		 */				public function sendAnswer( surveyID:int, answer:String ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_SEND_ANSWER + "/" + surveyID + "/" + "answers" );			var urlVars:URLVariables = new URLVariables();						urlVars.answer = answer;						request.data = urlVars;			request.method = URLRequestMethod.POST;						loader.errorHandler = errors.onSendAnswerError;			loader.completeHandler = onAnswerSent;			return startLoad( loader, request );		}				private function onAnswerSent( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_ANSWER_SENT, data, loader );		}				/**		 * 		 * @param	object		 */				public function getAnswers( surveyID:int ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_ANSWERS + "/" + surveyID + "/" + "answers" );			var urlVars:URLVariables = new URLVariables();						urlVars.group = "answer";			urlVars.order = "votes:desc";						request.data = urlVars;						loader.errorHandler = errors.onGetAnswersError;			loader.completeHandler = onAnswers;			return startLoad( loader, request );		}				private function onAnswers( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_ANSWERS, data, loader );		}				/**		 * 		 */				public function getLotteries( limit:int = 0, offset:int = 0 ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_LOTTERY );			var urlVars:URLVariables = new URLVariables();						urlVars.order = "date:desc";			urlVars.load = "winner.user";			if ( limit ) urlVars.limit = limit;			if ( offset ) urlVars.offset = offset;						request.data = urlVars						loader.errorHandler = errors.onGetLotteriesError;			loader.completeHandler = onLotteries;			return startLoad( loader, request );		}				private function onLotteries( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_LOTTERIES, data, loader );		}				/**		 * 		 * @param	id		 */				public function getLotteryByID( id:int ) {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_LOTTERY + "/" + id );			loader.errorHandler = errors.onGetLotteriesByIDError;			loader.completeHandler = onLottery;			return startLoad( loader, request );		}				private function onLottery( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_LOTTERY, data, loader );		}				/**		 * 		 * @param	id		 */				public function getEmployeeByID( id:int ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_EMPLOYEE + "/" + id );			var urlVars:URLVariables = new URLVariables();						urlVars.load = "user";			request.data = urlVars;						loader.errorHandler = errors.onGetEmployeeByIDError;			loader.completeHandler = onEmployeeByID;			return startLoad( loader, request );		}				private function onEmployeeByID( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_EMPLOYEE_DATA, data, loader );		}				/**		 * Возврощает список рейтингов		 * @param	limit		 * @param	offset		 * @param	positionSort сортировка по позиции. Допустимые значения Array.NUMERIC, Array.DESCENDING, null		 */				public function getRatings( limit:int = 1, offset:int = 0, sort:uint = Array.NUMERIC ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_RATINGS );			var urlVars:URLVariables = new URLVariables();						var orderRules:Array = [];						/*if ( checkSortMethodOnValid( positionSort ) ) {				//orderRules.push( "position:" + getSortMethodInAPIFormat( positionSort ) );							}*/						if ( sort === Array.NUMERIC ) {				orderRules.push( "rating:desc" );				orderRules.push( "created_at:asc" );				orderRules.push( "id:asc" );			} else {				orderRules.push( "rating:asc" );				orderRules.push( "created_at:desc" );				orderRules.push( "id:desc" );			}						urlVars.order = orderRules.toString();			if( limit ) urlVars.limit = limit;			urlVars.offset = offset;			request.data = urlVars;						loader.errorHandler = errors.onGetRatingsError;			loader.completeHandler = onRatings;			return startLoad( loader, request );		}					private function onRatings( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_RATINGS, data, loader );		}				/**		 * 		 * @param	lastName		 * @param	firstName		 * @param	middleName		 * @param	limit		 * @param	offset		 * @param	positionSort		 * @return		 */				public function searchRatings( lastName:String, firstName:String = "", middleName:String = "", limit:int = 1, offset:int = 0, sort:uint = Array.NUMERIC ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_RATINGS );			var urlVars:URLVariables = new URLVariables();			var searchParam:String;						var orderRules:Array = [];						/*if ( checkSortMethodOnValid( positionSort ) ) {				orderRules.push( "position:" + getSortMethodInAPIFormat( positionSort ) );			}*/						if ( sort === Array.NUMERIC ) {				orderRules.push( "rating:desc" );				orderRules.push( "created_at:asc" );				orderRules.push( "id:asc" );			} else {				orderRules.push( "rating:asc" );				orderRules.push( "created_at:desc" );				orderRules.push( "id:desc" );			}						searchParam = "last_name:" + lastName;			searchParam += ",first_name:" + (firstName ? firstName : lastName);			searchParam += ",middle_name:" + (middleName ? middleName : lastName);						urlVars.order = orderRules.toString();			urlVars.search = searchParam;			if ( limit ) urlVars.limit = limit;			urlVars.offset = offset;						request.data = urlVars;						loader.errorHandler = errors.onSearchRatingsError;			loader.completeHandler = onRatingsSearched;			return startLoad( loader, request );		}				private function onRatingsSearched( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_RATINGS_SEARCHED, data, loader );		}				/**		 * 		 */				public function getEmploeeLength():ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_EMPLOEES_LENGTH );			loader.errorHandler = errors.onGetEmployeesLengthError;			loader.completeHandler = onEmployeesLength;			return startLoad( loader, request );		}				private function onEmployeesLength( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_EMPLOYEES_LENGTH, data, loader );		}				/**		 * 		 * @return		 */				public function getOwnerRating():ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_OWNER_RATING );			loader.errorHandler = errors.onGetOwnerRatingError;			loader.completeHandler = onOwnerRating;			return startLoad( loader, request );		}				private function onOwnerRating( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_OWNER_RATING, data, loader );					}				/**		 * 		 */				public function getOwnerAlbums():ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_OWNER_ALBUMS );			loader.errorHandler = errors.onGetOwnerAlbumsError;			loader.completeHandler = onGetOwnerAlbums;			return startLoad( loader, request );		}				private function onGetOwnerAlbums( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_OWNER_ALBUMS, data, loader );		}				/**		 * 		 */				public function uploadPhoto( photo:ByteArray, message:String, departureID:String ):MultipartURLLoader {			var loader:MultipartURLLoader = new MultipartURLLoader();			var request:String = apiAddress + METHOD_UPLOAD_PHOTO;			request += "?auth_key=" + helper.getAuthKey();			request += "&user_id=" + helper.getUserID();			request += "&is_employee=" + int( helper.isEmployeeMode );						loader.addVariable( "anonce", message );			loader.addVariable( "departure_id", departureID );			loader.addFile( photo, "image.jpg", "photo", "image/jpg" );						loader.addEventListener( Event.COMPLETE, onPhotoUploaded );			loader.load( request );			return loader;		}				/**		 * 		 * @param	event		 */				private function onPhotoUploaded( event:Event ):void {			var loader:MultipartURLLoader = event.target as MultipartURLLoader;			var data:Object = JSON.parse( loader.loader.data ).response.data;			loader.removeEventListener( Event.COMPLETE, onPhotoUploaded );			loader.dispose();			loader = null;						dispatchComplete( ProviderEvent.ON_PHOTO_UPLOADED, data );		}				/**		 * 		 * @param	photoID		 * @param	newAnonce		 * @param	newDeparture		 */				public function updatePhoto( photoID:String, newAnonce:String, newDeparture:String ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_UPDATE_PHOTO + "/" + photoID );			var params:URLVariables = new URLVariables();						if( newAnonce ) params.anonce = newAnonce;			if( newDeparture ) params.departure_id = newDeparture;						request.method = URLRequestMethod.POST;			request.data = params;						loader.completeHandler = onPhotoUpdated;			loader.errorHandler = errors.onUpdatePhotoError;			return startLoad( loader, request );		}				private function onPhotoUpdated( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_PHOTO_UPDATED, data, loader );		}				/**		 * 		 * @param	photoID		 */				public function deletePhoto( photoID:String ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_DELETE_PHOTO + "/" + photoID );			request.method = URLRequestMethod.POST;			request.data = { };			loader.errorHandler = errors.onDeletePhotoError;			loader.completeHandler = onPhotoDeleted;			return startLoad( loader, request );		}				private function onPhotoDeleted( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_PHOTO_DELETED, data, loader );		}				/**		 * 		 */				public function getEmployeesPhotos( departure_id:String ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_DEPARTURE + "/" + departure_id + "/" + METHOD_GET_EMPLOYEES_PHOTOS );			loader.errorHandler = errors.onEmployeesPhotosError;			loader.completeHandler = onEmployeesPhotos;			return startLoad( loader, request );		}				private function onEmployeesPhotos( data:Object, loader:ProviderURLLoader ):void {			dispatchComplete( ProviderEvent.ON_EMPLOYEES_PHOTOS, data, loader );		}				/**		 * 		 * @param	name		 */				private function getPageByName( name:String, completeHandler:Function, errorHandler:Function ):ProviderURLLoader {			var loader:ProviderURLLoader = new ProviderURLLoader();			var request:URLRequest = new URLRequest( apiAddress + METHOD_GET_PAGE + "/" + name );			loader.errorHandler = errorHandler;			loader.completeHandler = completeHandler;			return startLoad( loader, request );		}				/**		 * 		 * @param	loader		 * @param	request		 */				private function startLoad( loader:ProviderURLLoader, request:URLRequest ):ProviderURLLoader {			loader.load( request );			dispatchEvent( new ProviderEvent( ProviderEvent.ON_LOAD_START ) );			return loader;		}				/**		 * 		 * @param	eventType		 * @param	data		 */				private function dispatchComplete( eventType:String, data:Object, loader:ProviderURLLoader = null ):void {			var event:ProviderEvent = new ProviderEvent( eventType );			if( data ) event.data = data;			dispatchEvent( event );			if ( loader ) loader.dispatchEvent( event );		}				/**		 * 		 * @param	methodInActionScriptFormat		 */				private function getSortMethodInAPIFormat( methodInActionScriptFormat:int ):String {			return methodInActionScriptFormat === Array.DESCENDING ? "desc" : "asc";		}				/**		 * 		 * @param	value		 * @return		 */				private function checkSortMethodOnValid( value:int ):Boolean {			return value === Array.NUMERIC || value === Array.DESCENDING;		}	}}