//
//  Global.h
//  VoIPModule
//
//  Created by Chen Xiangwen on 22/6/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#ifndef VoIPModule_Global_h
#define VoIPModule_Global_h

#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_IPHONE5 ([UIScreen mainScreen].bounds.size.height > 560.0)

// error code
#define NetworkNotReachable 0
#define Network3GNotEnabled 1
#define SipRegisterFailed   2
#define DecodeMessageContentFailed 3

#define kNotifKey									@"key"
#define kNotifKey_IncomingCall						@"icall"
#define kNotifKey_IncomingMsg						@"imsg"
#define kNotifIncomingCall_SessionId				@"sid"
#define kReceiveIncomingCallNotifName               @"ReceiveIncomingCall"

/* == Colors == */
#define kColorBlack				0x000000
#define kColorWhite				0xFFFFFF
#define kColorViolet			0x9900FF
#define kColorGray				0x736F6E
#define kColorBaloonOutTop		0xAFD662
#define kColorBaloonOutMiddle	0xBEDF7D
#define kColorBaloonOutBottom	0xD5E7B4
#define kColorBaloonOutBorder	0xC8E490
#define kColorBaloonInTop		0xDDDDDD
#define kColorBaloonInMiddle	0xD4D4D4
#define kColorBaloonInBottom	0xBEBEBE
#define kColorBaloonInBorder	0xBCBCBC

#define kColorsDarkBlack [NSArray arrayWithObjects: \
(id)[[UIColor colorWithRed:.1f green:.1f blue:.1f alpha:0.7] CGColor], \
(id)[[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.7] CGColor], \
nil]
#define kColorsBlue [NSArray arrayWithObjects: \
(id)[[UIColor colorWithRed:.0f green:.0f blue:.5f alpha:0.7] CGColor], \
(id)[[UIColor colorWithRed:0.f green:0.f blue:1.f alpha:0.7] CGColor], \
nil]
#define kColorsLightBlack [NSArray arrayWithObjects: \
(id)[[UIColor colorWithRed:.2f green:.2f blue:.2f alpha:0.7] CGColor], \
(id)[[UIColor colorWithRed:.1f green:.1f blue:.1f alpha:0.7] CGColor], \
(id)[[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.7] CGColor], \
nil]

#define kButtonStateAll (UIControlStateSelected | UIControlStateNormal | UIControlStateHighlighted | UIControlStateDisabled | UIControlStateApplication)


#define kCallTimerSuicide	1.5f

/* == Images for VideoCall Screen */
#define kImageVCMute	@"mute"
#define kImageVCMuteSel	@"muteSel"

#define kImageBaloonIn @"baloon_in"
#define kImageBaloonOut @"baloon_out"


#define kBaseURL @"http://112.124.36.134:8080"
#define kSemiModalAnimationDuration 0.3f

#define PageWidth 340

#define kImagePath @"IMAGEPATH"
#define kImageTransCompletion @"IMAGETRANSCOMPLETION"
#define kAddNewImage @"NewImages"
#define kSeparator  @"**||**"

#define kScrollOffset @"SCROLLOFFSET"
#define kLongPressIndicator @"LONGPRESSINDICATOR"
#define kDoodleImageIndex @"DOODLEINDEX"
#define kDoodleImagePoints @"DOODLEPOINTS"
#define kDoodleCancel @"DOODLECANCEL"
#define kCancelAddImage @"CANCELADDIMAGE"
#define kNewImageComing @"NEWIMAGECOMING"

#define kBeginVideo @"BEGINVIDEO"
#define kPlayVideo @"PLAYVIDEO"
#define kVideoCancel @"VIDEOCANCEL"
#define kVideoSyn @"VIDEOSYN"
#define kImageDispCancel @"IMAGEDISPCANCEL"
#define kVideoPlayerCancel @"PLAYERCANCEL"
#define kVideoPlaying @"VIDEOPLAYING"
#define kVideoStop @"VIDEOSTOP"
#define kVideoPaused @"VIDEOPAUSEDL"
#define kVideoBackward @"VIDEOBACKWARD"
#define kVideoForward @"VIDEOFORWARD"
#define kVideoInterrupted @"VIDEOINTERRUPTED"
#define kVideoHideControls 4

#define kHandDrawing @"HANDDRAW"
#define kHandDrawingRevoke @"HandDrawingRevoke"
#define kDrawingPoints @"DRAWINGPOINTS"
#define kCancelDrawing @"CANCELDRAWING"
#define kAppointment @"APPOINTMENT"
#define kBeginImage @"BEGINIMAGE"
#define kBeginShopping @"BEGINSHOPPING"
#define kCancelShopping @"CANCELSHOPPING"
#define kBeginBrowser @"BEGINBROWSER"

#define kShoppingSyn @"SHOPPINGSYN"
#define kSynReceived @"SYNRECEIVED"
#define kBrowserSyn @"BROWSERSYN"
#define kCancelBrowser @"CANCELBROWSER"
#define kClearAllHandWriting @"CLEARHANDWRITING"
#define kClearAllDoodle @"CLEARDOODLE"
#define kHangUpcall @"hangUpCall"

#define kInterruption @"interruption"
#define kChangeNetWork @"changenetwork"
#define kInterruptionOK @"interruptionOK"
#define kChangeNetworkOK @"changenetworkOK"
#define kWillChangeNetwork @"willchangenetwork"

#define kProfileSize  320
#define avatarDiameter 30

// detail history
#define kImageViewTagInContentView 180
#define kSelectingImageTag 10000
#define HistoryImageSize 40

#define kCellTopHeight		 20.f
#define kCellBottomHeight	 20.f
#define kCellDateHeight		 20.f
#define kCellContentFontSize 17.f

#define kBalloonOutSideMargin 20.f
#define kBalloonInSideMargin 4.f
#define kContentMarginLeft 10.f
#define kContentMarginRight 10.f
#define kCellEditMargin		 20.f

#define tertiaryColor [UIColor colorWithRed:130/255.0 green:130/255.0 blue:130/255.0 alpha:1.0f]
#define primaryColor [UIColor colorWithRed:143/255.0 green:74/255.0 blue:67/255.0 alpha:1.0f]
#define secondaryColor [UIColor colorWithRed:21/255.0 green:21/255.0 blue:21/255.0 alpha:1.0f]

#define kMainHistAppMark @"MainHistAppoinment"

// Umeng SDK Key
#define kUmengSDKKey @"527c513f56240b352905fbfb"
#define kSingUpKey @"SignedUp"
#define kWaitingKey @"InWaitingList"

//notification
#define kHistoryChangedNotification @"HistoryChanged"

#define MaxDrawPoints 100

// history
#define kHistoryEventStatus_Appointment @"HistoryEventStatus_Appointment"
#define kHistoryEventStatus_Outgoing @"HistoryEventStatus_Outgoing"
#define kHistoryEventStatus_OutgoingCancelled @"HistoryEventStatus_OutgoingCancelled"
#define kHistoryEventStatus_Incoming @"HistoryEventStatus_Incoming"
#define kHistoryEventStatus_IncomingRejected @"HistoryEventStatus_IncomingRejected"
#define kHistoryEventStatus_OutgoingRejected @"HistoryEventStatus_OutgoingRejected"
#define kHistoryEventStatus_IncomingCancelled @"HistoryEventStatus_IncomingCancelled"
#define kHistoryEventStatus_Missed @"HistoryEventStatus_Missed"

#define kMediaType_None @"kMediaType_None"
#define kMediaType_Audio @"MediaType_Audio"
#define kMediaType_Video @"MediaType_Video"
#define kMediaType_Image @"MediaType_Image"

//doodle
#define kDoodleLineWidth @"doodlelinewidth"
#define kDoodleEraseWidth @"doodleerasewidth"
#define kDoodleLineColor @"doodlelinecolor"

//waitinglist
#define kCheckStatusNotification @"statusnotification"
#define kAddPartnerNotification @"addpartnernotification"

//QianLi Robot
#define QianLiRobotNumber @"008600000000000"

extern bool kIsCallingQianLiRobot;
extern int kQianLiRobotSharedPhotoNum;
extern int kQianLiRobotSharedDoodleNum;
extern int kQianLiRobotSharedWebNum;
extern int kQianLiRobotsharedVideoNum;

#endif
