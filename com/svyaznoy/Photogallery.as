﻿package com.svyaznoy {	import caurina.transitions.Tweener;	import com.flashgangsta.managers.MappingManager;	import com.flashgangsta.net.ContentLoader;	import com.flashgangsta.utils.PopupsController;	import com.svyaznoy.events.ProviderEvent;	import com.svyaznoy.gui.Button;	import flash.display.Bitmap;	import flash.display.DisplayObject;	import flash.display.MovieClip;	import flash.display.Sprite;	import flash.events.Event;	import flash.events.IOErrorEvent;	import flash.events.MouseEvent;	import flash.events.SecurityErrorEvent;	import flash.geom.Rectangle;		/**	 * ...	 * @author Sergey Krivtsov (flashgangsta@gmail.com)	 */		public class Photogallery extends Popup {				private const BORDER_MARGIN:int = 10;				private var commentsWidth:int = 207;		private var data:Object;		private var provider:Provider = Provider.getInstance();		private var toGalleryButton:Button;		private var maskObject:DisplayObject;		private var previews:PhotogalleryPreviews;		private var preloader:MovieClip;		private var bitmap:Bitmap;		private var loader:ContentLoader = new ContentLoader();		private var errors:Errors = Errors.getInstance();		private var area:Rectangle;		private var frame:Sprite;		private var nextButton:Button;		private var prevButton:Button;		private var photosDatasList:Array;		private var _width:int;		private var comments:Comments;		private var photoData:Object;		private var like:LikeComponent;		private var authorBar:WorkAuthorBar;						/**		 * 		 * @param	data		 */				public function Photogallery( isContest:Boolean = false ) {			toGalleryButton = getChildByName( "toGalleryButton_mc" ) as Button;			maskObject = getChildByName( "maskObject_mc" );			previews = getChildByName( "previews_mc" ) as PhotogalleryPreviews;			preloader = getChildByName( "preloader_mc" ) as MovieClip;			frame = getChildByName( "frame_mc" ) as Sprite;			nextButton = getChildByName( "next_mc" ) as Button;			prevButton = getChildByName( "prev_mc" ) as Button;						toGalleryButton.visible = !isContest;						if ( !Helper.getInstance().isEmployeeMode ) {				commentsWidth = 0;			}						Sprite( background ).mouseChildren = Sprite( background ).mouseEnabled = false;						_width = frame.width;						prevButton.visible = nextButton.visible = false;						PopupsController.getInstance().setBlockRect( 0x2b2927, .85 );						previews.addEventListener( Event.SELECT, onPhotoSelect );			maskObject.visible = false;			toGalleryButton.visible = false;			area = maskObject.getBounds( this );						loader.addEventListener( Event.COMPLETE, onLoaded );			loader.addEventListener( IOErrorEvent.IO_ERROR, onIOError );			loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );						nextButton.addEventListener( MouseEvent.CLICK, onNextClicked );			prevButton.addEventListener( MouseEvent.CLICK, onPrevClicked );			frame.addEventListener( MouseEvent.CLICK, onNextClicked );						frame.buttonMode = true;		}				/**		 * 		 * @param	data		 */				public function loadByPreviewData( data:Object ):void {			provider.getGalleryPhotos( data.departure_id, data.id );			provider.addEventListener( ProviderEvent.ON_GALLERY_PHOTOS, onData );		}				/**		 * 		 * @param	data		 */				public function showGallery( data:Object ):void {			this.data = data;			photosDatasList = data.photos;			previews.fill( photosDatasList );			prevButton.visible = nextButton.visible = photosDatasList.length > PhotogalleryPreviews.STEP_ITEMS_LENGTH;			updateButtons();		}				/**		 * 		 */				override public function get width():Number {			return _width;		}				/**		 * 		 */				private function updateButtons():void {			if ( !prevButton.visible && !nextButton.visible ) return;						var selectedIndex:int = previews.getSelectedPhotoIndex();			var lastPhotoIndex:int = photosDatasList.length - 1;						if ( selectedIndex === 0 && prevButton.enabled ) {				prevButton.enabled = false;				prevButton.setDefaultState();			} else if ( selectedIndex && !prevButton.enabled ) {				prevButton.enabled = true;			}						if ( selectedIndex === lastPhotoIndex && nextButton.enabled ) {				nextButton.enabled = false;				nextButton.setDefaultState();			} else if ( selectedIndex !== lastPhotoIndex && !nextButton.enabled ) {				nextButton.enabled = true;			}		}				/**		 * 		 */				override public function dispose():void {			super.dispose();			if( provider ) {				if( provider.hasEventListener( ProviderEvent.ON_GALLERY_PHOTOS ) ) {					provider.removeEventListener( ProviderEvent.ON_GALLERY_PHOTOS, onData );				}				provider = null;			}						if ( loader ) {				loader.close();				loader.removeEventListener( Event.COMPLETE, onLoaded );				loader.removeEventListener( IOErrorEvent.IO_ERROR, onIOError );				loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );				loader = null;			}		}				/**		 * 		 * @param	datasList		 */				public function loadByDatasList( datasList:Array ):void {			showGallery( { photos: datasList } );		}				/**		 * 		 * @param	event		 */				private function onData( event:ProviderEvent ):void {			provider.removeEventListener( ProviderEvent.ON_GALLERY_PHOTOS, onData );			showGallery( event.data );		}				/**		 * 		 * @param	event		 */				private function onPhotoSelect( event:Event ):void {			photoData = previews.getSelectedPhotoData();			if( bitmap ) {				Tweener.removeTweens( frame );				Tweener.removeTweens( bitmap );				if( contains( bitmap ) ) removeChild( bitmap );				bitmap.bitmapData.dispose();				bitmap = null;				loader.close();			}			showPreloader();			loader.load( photoData.photo_with_path );			updateButtons();						if ( comments ) { 				comments.dispose();				removeChild( comments.view );				comments = null;			}						if ( like ) {				like.dispose();				removeChild( like );				like = null;			}						if ( authorBar ) {				authorBar.dispose();				removeChild( authorBar );				authorBar = null;			}		}				/**		 * 		 * @param	event		 */				private function onNextClicked( event:MouseEvent ):void {			previews.selectNextPhoto();		}				/**		 * 		 * @param	event		 */				private function onPrevClicked( event:MouseEvent ):void {			previews.selectPrevPhoto();		}				/**		 * 		 * @param	event		 */				private function onLoaded( event:Event ):void {			hidePreloader();			bitmap = loader.getContent() as Bitmap;			bitmap.smoothing = true;			MappingManager.setScaleOnlyReduce( bitmap, area.width, area.height );						var frameHeight:Number = Math.round( bitmap.height + BORDER_MARGIN * 2 );			var frameWidth:Number =  Math.round( bitmap.width + BORDER_MARGIN * 2 );						if ( !(frameHeight / 2 is int) ) frameHeight -= 1;						if( commentsWidth ) {				if ( photoData.gallery_id ) {					trace( "is gallery photo" );					comments = new GalleryComments( data.departure_id, photoData.gallery_id, photoData.id );				} else if ( photoData.competition_id ) {					trace( "is competition photo" );					comments = new ContestsComments( photoData.competition_id, photoData.id );					authorBar = new WorkAuthorBar();					authorBar.loadAvatar( photoData.employee.user.username );					authorBar.title = photoData.employee.full_title;					authorBar.message = photoData.title;					authorBar.alpha = 0;					addChild( authorBar );				} else {					trace( "is employee photo" );					comments = new EmployeePhotoComments( photoData.departure_id, photoData.id );				}								if ( photoData.is_can_be_voted ) {					like = new LikeComponent( photoData );					like.likes = photoData.likes;					like.alpha = 0;					addChild( like );					comments.height = frameHeight - like.height - authorBar.height;				} else {					comments.height = authorBar ? frameHeight - authorBar.height : frameHeight;				}				frameWidth = Math.round( frameWidth + commentsWidth );				if ( !(frameWidth / 2 is int) ) frameWidth -= 1;				comments.view.alpha = 0;				addChild( comments.view );				onFrameSizeUpdated();				Tweener.addTween( frame, { width: frameWidth, height: frameHeight, time: .5, transition: "easeInOutCubic", onUpdate: onFrameSizeUpdated, onComplete: onFrameScaled } );			} else {				if ( !(frameWidth / 2 is int) ) frameWidth -= 1;				Tweener.addTween( frame, { width: frameWidth, height: frameHeight, time: .5, transition: "easeInOutCubic", onComplete: onFrameScaled } );			}		}				/**		 * 		 */				private function onFrameSizeUpdated():void {			var frameBounds:Rectangle = frame.getBounds( this );			if ( comments ) {				comments.view.x = Math.round( frameBounds.x + frameBounds.width - commentsWidth );				if ( authorBar ) {					authorBar.y = frameBounds.y + BORDER_MARGIN;					comments.view.y = authorBar.y + authorBar.height;					authorBar.x = comments.view.x;				} else {					comments.view.y = frameBounds.y;				}			}						if ( like ) {				like.y = Math.floor( frameBounds.y + frameBounds.height - like.height );				like.x = Math.floor( frameBounds.x + frameBounds.width - like.width );			}		}				/**		 * 		 */				private function onFrameScaled():void {			var frameBounds:Rectangle = frame.getBounds( this );			frame.width = Math.round( frame.width );			frame.height = Math.round( frame.height );			frame.x = Math.round( frame.x );			frame.y = Math.round( frame.y );						if ( comments ) {				onFrameSizeUpdated();				comments.view.alpha = 0;				Tweener.addTween( comments.view, { alpha: 1, time: 1, transition: "easeInOutCubic" } );			}						if ( like ) {				like.alpha = 0;				Tweener.addTween( like, { alpha: 1, time: 1, transition: "easeInOutCubic" } );			}						if ( authorBar ) {				authorBar.alpha = 0;				Tweener.addTween( authorBar, { alpha: 1, time: 1, transition: "easeInOutCubic" } );			}						bitmap.alpha = 0;			bitmap.x = frameBounds.x + BORDER_MARGIN;			bitmap.y = frameBounds.y + BORDER_MARGIN;			Tweener.addTween( bitmap, { alpha: 1, time: 1, transition: "easeInOutCubic" } );						trace( frameBounds );			trace( frame.x, frame.y, frame.width, frame.height );						addChild( bitmap );		}				/**		 * 		 * @param	event		 */				private function onIOError( event:IOErrorEvent ):void {			errors.ioError( event );			hidePreloader();		}				/**		 * 		 * @param	event		 */				private function onSecurityError( event:SecurityErrorEvent ):void {			errors.securityError( event );			hidePreloader();		}				/**		 * 		 */				private function hidePreloader():void {			if ( !preloader.visible ) return;			preloader.stop();			preloader.visible = false;		}				/**		 * 		 */				private function showPreloader():void {			if ( preloader.visible ) return;			preloader.play();			preloader.visible = true;			addChild( preloader );		}			}}