package com.svyaznoy {	import com.flashgangsta.managers.MappingManager;	import flash.display.Sprite;	import flash.text.TextFormat;		/**	 * ...	 * @author Sergey Krivtsov (flashgangsta@gmail.com)	 */	public class ProfilePhotosDepartureBar extends Sprite {				private const ROW_COUNT:int = 3;		private const MARGIN_H:int = 20;				private var button:DeparturesPhotosButton;		private var datasList:Vector.<Object>;		private var images:Vector.<PreviewDepartureImage> = new Vector.<PreviewDepartureImage>();		private var imagesContainer:Sprite = new Sprite();		private var nameTextFormat:TextFormat;		private var lengthTextFormat:TextFormat;				/**		 * 		 * @param	datasList		 */				public function ProfilePhotosDepartureBar( datasList:Vector.<Object> ) {			this.datasList = datasList;			button = getChildByName( "button_mc" ) as DeparturesPhotosButton;			nameTextFormat = button.getLabelTextFormat();			lengthTextFormat = button.getLabelTextFormat();			lengthTextFormat.color = 0xFFFFFF;			lengthTextFormat.size = 14;			setLabel();			addImages();			button.enabled = button.iconVisible = datasList.length > ROW_COUNT;		}				/**		 * 		 */				public function setLabel():void {			var lengthMessage:String = " (" + datasList.length + " фото)";			var name:String = datasList[ 0 ].departureName;			var message:String = name + lengthMessage;			button.setLabel( message.toUpperCase() ) ;			button.setLabelTextFormat( nameTextFormat, -1, name.length );			button.setLabelTextFormat( lengthTextFormat, name.length + 1, message.length );			button.setLabel( message.toUpperCase() ) ;		}				/**		 * 		 */				private function addImages():void {			var length:int = Math.min( datasList.length, ROW_COUNT );			var image:PreviewDepartureImage;						for ( var i:int = 0; i < length; i++ ) {				image = new PreviewDepartureImage( datasList[ i ] );				image.x = Math.round( ( image.width + MARGIN_H ) * ( i % ROW_COUNT ) );								imagesContainer.addChild( image );			}						imagesContainer.y = MappingManager.getBottom( button, this ) + 10;			addChild( imagesContainer );		}			}}