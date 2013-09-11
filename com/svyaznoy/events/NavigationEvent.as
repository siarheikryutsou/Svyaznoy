﻿package com.svyaznoy.events {	import com.svyaznoy.Ratings;	import com.svyaznoy.ThermsOfMotivation;	import flash.events.Event;		/**	 * ...	 * @author Sergey Krivtsov (flashgangsta@gmail.com)	 */	public class NavigationEvent extends Event {				/// Выезды		static public const NAVIGATE_TO_DEPARTURES:String = "navigateToDepartures";		/// Новости		static public const NAVIGATE_TO_NEWS:String = "navigateToNews";		/// Легенда		static public const NAVIGATE_TO_LEGEND:String = "navigateToLegend";		/// Конкурсы		static public const NAVIGATE_TO_CONTESTS:String = "navigateToContests";		/// О связном		static public const NAVIGATE_TO_ABOUT:String = "navigateToAbout";		/// Радио		static public const NAVIGATE_TO_RADIO:String = "navigateToRadio";		/// Условия мотивации		static public const NAVIGATE_TO_THERMS_OF_MOTIVATION:String = "navigateToThermsOfMotivation";		/// Видео отчеты		static public const NAVIGATE_TO_VIDEO_REPORT:String = "navigateToVideoReport";		/// Рейтинги		static public const NAVIGATE_TO_RATINGS:String = "navigateToRatings";		/// Личный кабинет		static public const NAVIGATE_TO_PROFILE:String = "navigateToProfile";		/// Анонс		static public const NAVIGATE_TO_ANNOUNCEMENT:String = "navigateToAnnouncement";						/**		 * 		 * @param	type		 * @param	bubbles		 * @param	cancelable		 */				public function NavigationEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false ) { 			super( type, bubbles, cancelable );		} 				public override function clone():Event { 			return new NavigationEvent( type, bubbles, cancelable );		} 				public override function toString():String { 			return formatToString( "NavigationEvent", "type", "bubbles", "cancelable", "eventPhase" ); 		}			}	}