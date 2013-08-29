package com.svyaznoy {	import com.flashgangsta.managers.MappingManager;	import com.flashgangsta.ui.CheckBox;	import com.svyaznoy.gui.Button;	import com.svyaznoy.gui.VotingPopupCheckBox;	import com.svyaznoy.gui.VotingPopupInput;	import com.svyaznoy.modules.Answer;	import com.svyaznoy.modules.Voting;	import com.svyaznoy.utils.ColorChanger;	import flash.display.DisplayObject;	import flash.display.Sprite;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.text.TextField;	import flash.text.TextFieldAutoSize;		/**	 * ...	 * @author Sergey Krivtsov (flashgangsta@gmail.com)	 */	public class VotingPopup extends Popup {				private const MARGIN:int = 20;				private var withCustomAnswer:Boolean;		private var answersContainer:Sprite = new Sprite();		private var questionLabel:TextField;		private var voteButton:Button;		private var selectedItem:DisplayObject;		private var customAnswer:VotingPopupInput;		private var answersList:Vector.<VotingPopupCheckBox> = new Vector.<VotingPopupCheckBox>();				/**		 * 		 * @param	question		 * @param	type		 * @param	answersList		 * @param	withCustomAnswer		 */				public function VotingPopup( question:String, type:String, answersList:Vector.<String>, withCustomAnswer:Boolean = false ) {			this.withCustomAnswer = withCustomAnswer;			var answerClass:Class = type === Voting.TYPE_SINGLE ? VotingPopupRadioButtonView : VotingPopupCheckBoxView;			var answer:VotingPopupCheckBox;						questionLabel = getChildByName( "question_txt" ) as TextField;			questionLabel.autoSize = TextFieldAutoSize.LEFT;			questionLabel.text = question;						voteButton = getChildByName( "voteButton_mc" ) as Button;			voteButton.setLabel( "ПРОГОЛОСОВАТЬ!" );			voteButton.enabled = false;			voteButton.addEventListener( MouseEvent.CLICK, onClicked );						for( var i:int = 0; i < answersList.length; i++ ) {				answer = new answerClass();				answer.value = answersList[ i ];				answer.y = Math.round( answersContainer.height );				ColorChanger.setColorByIndex( answer.getIconBackground(), i );				answersContainer.addChild( answer );				this.answersList.push( answer );			}						if ( withCustomAnswer ) {				customAnswer = new VotingPopupInput( type );				customAnswer.y = Math.round( answersContainer.height );				ColorChanger.setColorByIndex( customAnswer.getIconBackground(), i );				answersContainer.addChild( customAnswer );			}						addEventListener( Event.SELECT, type === Voting.TYPE_SINGLE ? onItemSingleSelect : onMultiItemSelect );						answersContainer.x = MappingManager.getCentricPoint( width, answersContainer.width );			answersContainer.y = MappingManager.getBottom( questionLabel, this ) + MARGIN;			voteButton.y = MappingManager.getBottom( answersContainer, this ) + MARGIN;			background.height = MappingManager.getBottom( voteButton, this ) + MARGIN - background.y;						addChild( answersContainer );						trace( "VotingPopup", type, "with" + ( withCustomAnswer ? "" : "out" ) + " custom answer" );		}				/**		 * 		 */				public function getAnswers():Array {			var customAnswer:VotingPopupInput;			var result:Array = [];			var lastAnswerIndex:int = answersContainer.numChildren - 1;			var answer:CheckBox;						if ( customAnswer ) {				lastAnswerIndex--;				if ( customAnswer.selected && customAnswer.getValue() ) {					result.push( customAnswer.getValue() );				}			}						for ( var i:int = 0; i < answersList.length; i++ ) {				answer = answersList[ i ] as CheckBox;				if ( answer.selected ) {					result.push( answer.value );				}			}			return result;		}				/**		 * 		 */				override public function dispose():void {			var answer:CheckBox;			super.dispose();			trace( "voting popup dispose" );			if ( customAnswer ) {				customAnswer.dispose();			}			for ( var i:int = 0; i < answersList.length; i++ ) {				answer = answersList[ i ] as CheckBox;				answer.dispose();			}			answersList = new Vector.<VotingPopupCheckBox>();			voteButton.dispose();		}				/**		 * 		 * @param	event		 */				private function onClicked( event:MouseEvent ):void {			answersContainer.mouseEnabled = false;			answersContainer.mouseChildren = false;			voteButton.enabled = false;			answersContainer.alpha = .5;			dispatchEvent( new Event( Event.COMPLETE ) );		}				/**		 * 		 */				private function onMultiItemSelect( event:Event ):void {			var ownSelection:Boolean = false;			for ( var i:int = 0; i < answersContainer.numChildren; i++ ) {				if ( answersContainer.getChildAt( i )[ "selected" ] ) {					ownSelection = true;					break;				}			}			voteButton.enabled = ownSelection;		}				/**		 * 		 * @param	event		 */				private function onItemSingleSelect( event:Event ):void {			if ( selectedItem ) {				if ( selectedItem === event.target ) {					voteButton.enabled = false;					selectedItem = null;					return;				}				selectedItem[ "selected" ] = false;			} else {				voteButton.enabled = true;			}			selectedItem = event.target as DisplayObject;		}			}}