﻿package com.svyaznoy {	import com.flashgangsta.managers.MappingManager;	import com.flashgangsta.media.video.YoutubePlayer;	import com.svyaznoy.events.PreviewsTableEvent;	import com.svyaznoy.events.ProviderEvent;	import com.svyaznoy.events.ScreenEvent;	import flash.geom.Rectangle;	import flash.text.TextField;	import flash.text.TextFieldAutoSize;		/**	 * ...	 * @author Sergey Krivtsov (flashgangsta@gmail.com)	 */		public class VideoReport extends ReportScreen {				private const TITLE_BOTTOM_MARGIN:int = 10;		private const VIDEO_TITLE_BOTTOM_MARGIN:int = -3;		private const VIDEO_DESCRIPTION_BOTTOM_MARGIN:int = 7;		private const PREVIEWS_TOP_MARGIN:int = 15;				private var currentVideoIndex:int = 0;		private var player:YoutubePlayer;		private var videoTitleLabel:TextField;		private var videoDescriptionLabel:TextField;		private var screenRectangle:Rectangle;		private var startFromVideo:String;		private var comments:VideoComments;				/**		 * 		 */				public function VideoReport() {			player = getChildByName( "player_mc" ) as YoutubePlayer;			videoTitleLabel = getChildByName( "videoTitleLabel_txt" ) as TextField;			videoDescriptionLabel = getChildByName( "videoDescriptionLabel_txt" ) as TextField;						videoTitleLabel.autoSize = TextFieldAutoSize.LEFT;			videoDescriptionLabel.autoSize = TextFieldAutoSize.LEFT;						setElementsForVisibleControll( player, videoTitleLabel, videoDescriptionLabel );			setVisibleForElements( false );						screenRectangle = Helper.getInstance().getScreenRectangle();		}				/**		 * 		 */				public function loadReport( id:int, startFromVideo:String = null ):void {			this.startFromVideo = startFromVideo;			if ( data && data.id === id ) {				if ( previewsTable && startFromVideo !== previewDatasList[ currentVideoIndex ].video ) {					previewsTable.selectItemByVideo( startFromVideo );				}				return;			}						clear();			addPreloader();			provider.getVideoReportByID( id );			provider.addEventListener( ProviderEvent.ON_VIDEO_REPORT, onData );			dispatchHeighUpdated();		}				/**		 * 		 */				override protected function clear():void {			super.clear();			setPositions();		}				/**		 * 		 * @param	event		 */				override protected function onData( event:ProviderEvent ):void {			var data:Object = event.data;			provider.removeEventListener( ProviderEvent.ON_VIDEO_REPORT, onData );			data.id = int( data.id );			super.onData( event );			initNewReport();		}				/**		 * 		 * @param	departureData данные о выезде, содержат поля:			 * id:int			 * title:String			 * year:int			 * start:String			 * galleries:Array			 * videos:Array			 * full_title:String			 * image_with_path:String		 */				override public function showReport( departureData:Object ):void {			super.showReport( departureData );			if ( !needUpdate ) return;			initNewReport();		}				/**		 * 		 */				override protected function displayData():void {			super.displayData();			title.appendText( ": ВИДЕООТЧЁТЫ" );			videoTitleLabel.y = MappingManager.getBottom( title, this ) + TITLE_BOTTOM_MARGIN;			initPreviews();			initVideo( previewDatasList[ currentVideoIndex ] );			setVisibleForElements( true );			dispatchHeighUpdated();		}				/**		 * 		 */				override protected function initPreviews():void {			super.initPreviews();						if( previewDatasList.length > 1 ) {				previewsTable = new PreviewsTable();				previewsTable.fill( previewDatasList, PreviewVideo, currentVideoIndex );				previewsTable.addEventListener( PreviewsTableEvent.ON_PREVIEW_SELECTED, onPreviewSelected );				addChild( previewsTable );			}		}				/**		 * 		 * @param	event		 */				override protected function onPreviewSelected( event:PreviewsTableEvent ):void {			super.onPreviewSelected( event );						var previewData:Object = previewsTable.getSelectedItemData();			currentVideoIndex = previewDatasList.indexOf( previewData );			previewsTable.refill( currentVideoIndex );			initVideo( previewData, true );						dispatchHeighUpdated();						if ( player.getBounds( stage ).y < screenRectangle.y ) {				Dispatcher.getInstance().dispatchEvent( new ScreenEvent( ScreenEvent.RESET_SCROLL_NEEDED ) );			}		}				/**		 * 		 */				private function initNewReport():void {			previewDatasList = data.videos;			if ( startFromVideo ) {				for ( var i:int = 0; i < previewDatasList.length; i++ ) {					if ( previewDatasList[ i ].video === startFromVideo ) {						currentVideoIndex = i;						break;					}				}				startFromVideo = null;			} else {				currentVideoIndex = 0;			}						if ( comments ) {				comments.dispose();				removeChild( comments.view );				comments = null;			}						displayData();		}				/**		 * 		 * @param	videoData данные о видео, содержат следующие параметры:			 * id:int			 * departure_id:int			 * title:String			 * anonce:String			 * video:String - идентификатор видео			 * secured:int			 * status:int			 * created_at:String			 * updated_at:String		 */				private function initVideo( videoData:Object, autoplay:Boolean = false ):void {			videoTitleLabel.text = videoData.title;			videoDescriptionLabel.text = videoData.anonce;			player.stop();			player.setVideo( videoData.video, autoplay );						comments = new VideoComments( videoData.departure_id, videoData.id );			comments.width = player.width;			addChild( comments.view );						setPositions();		}				/**		 * 		 */				private function setPositions():void {			videoDescriptionLabel.y = MappingManager.getBottom( videoTitleLabel, this ) + VIDEO_TITLE_BOTTOM_MARGIN;			player.y = MappingManager.getBottom( videoDescriptionLabel, this ) + VIDEO_DESCRIPTION_BOTTOM_MARGIN;						if ( comments ) comments.view.y = MappingManager.getBottom( player, this ) + MARGIN;						if ( !previewsTable ) {				bottomButton.y = ( comments ? MappingManager.getBottom( comments.view, this ) : MappingManager.getBottom( player, this ) ) + ScreenWithBottomButton.MARGIN;			} else {				previewsTable.y = ( comments ? MappingManager.getBottom( comments.view, this ) : MappingManager.getBottom( player, this ) ) + PREVIEWS_TOP_MARGIN;								if( previewsTable.numChildren ) {					bottomButton.y = MappingManager.getBottom( previewsTable, this ) + ScreenWithBottomButton.MARGIN;				} else {					bottomButton.y = ( comments ? MappingManager.getBottom( comments.view, this ) : MappingManager.getBottom( player, this ) ) + ScreenWithBottomButton.MARGIN;				}			}		}			}}