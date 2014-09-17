//
//  MDConstants.h
//  iOSMedableSDK
//

//  Copyright (c) 2014 Medable. All rights reserved.
//


#pragma mark - Environment
extern NSString* const kConfigurationKey;
extern NSString* const kEnvironmentsFileName;
extern NSString* const kBaseURLKey;
extern NSString* const kAPIPrefixKey;
extern NSString* const kProtocolKey;
extern NSString* const kOrgKey;

#pragma mark - APIClient
extern NSString* const kMedableClientKey;
extern NSString* const kMedableCSRFKey;
extern NSString* const kAcceptHeaderKey;
extern NSString* const kAcceptApplicationJsonKey;
extern NSString* const kAcceptLanguageKey;
extern NSString* const kAuthKey;
extern NSString* const kLoginKey;
extern NSString* const kLogoutKey;
extern NSString* const kRequestPasswordRequestKey;
extern NSString* const kResetPasswordKey;
extern NSString* const kResultKey;
extern NSString* const kFaultKey;
extern NSString* const kIdKey;
extern NSString* const kBundleKey;
extern NSString* const kBundleVersionKey;
extern NSString* const kBundleUrlKey;
extern NSString* const kRegisterKey;
extern NSString* const kPasswordKey;
extern NSString* const kOldPasswordKey;
extern NSString* const kConfirmPasswordKey;
extern NSString* const kLocationKey;
extern NSString* const kNotificationTokenKey;
extern NSString* const kSpecialty;
extern NSString* const kOrganization;
extern NSString* const kNotificationsKey;
extern NSString* const kPatientConnectedKey;
extern NSString* const kLocationNameKey;
extern NSString* const kSingleUseKey;
extern NSString* const kVerificationTokenKey;
extern NSString* const kRoleKey;
extern NSString* const kRolesKey;
extern NSString* const kRolePatient;
extern NSString* const kRoleProvider;
extern NSString* const kBodyKey;
extern NSString* const kLimitKey;
extern NSString* const kSkipKey;
extern NSString* const kSortKey;
extern NSString* const kRangeStartKey;
extern NSString* const kRangeEndKey;
extern NSString* const kRangeFieldKey;
extern NSString* const kPreviousKey;
extern NSString* const kAscendingKey;
extern NSString* const kAccountRolesKey;
extern NSString* const kTokenKey;
extern NSString* const kHttpGetKey;
extern NSString* const kHttpPostKey;
extern NSString* const kHttpPutKey;
extern NSString* const kHttpDeleteKey;
extern NSString* const kHttpPatchKey;
extern NSString* const kFilterCallerKey;
extern NSString* const kFilterCallerOnUrlParameter;
extern NSString* const kInvitationsUrlParameter;
extern NSString* const kSentInvitationsUrlParameter;
extern NSString* const kHasPatientParameter;
extern NSString* const kFavoritesKey;
extern NSString* const kTargetKey;
extern NSString* const kTargetsKey;
extern NSString* const kMimeTypeImageJpeg;
extern NSString* const kMimeTypeImagePng;
extern NSString* const kMimeTypeApplicationOctet;
extern NSString* const kTransferKey;
extern NSString* const kConnectKey;
extern NSString* const kAccessLevelKey;
extern NSString* const kIncludeKey;
extern NSString* const kExpandKey;
extern NSString* const kPathsKey;
extern NSString* const kSearchKey;
extern NSString* const kPatientKey;
extern NSString* const kFileKey;
extern NSString* const kOverlayKey;
extern NSString* const k__post___Key;
extern NSString* const k__body___Key;
extern NSString* const kAttachmentKey;
extern NSString* const kLastBundleVersion;

#pragma mark - Bundle
extern NSString* const kVersionKey;
extern NSString* const kLocaleKey;
extern NSString* const kFaultsKey;
extern NSString* const kDermtapKey;
extern NSString* const kDiagnosisKey;
extern NSString* const kDiagnosesKey;
extern NSString* const kTreatmentsKey;
extern NSString* const kStringsKey;
extern NSString* const kExclusiveKey;

#pragma mark - Tutorial
extern NSString* const kTutorialProgressFileName;
extern NSString* const kScreensKey;
extern NSString* const kActionsKey;
extern NSString* const kTutorialsKey;
extern NSString* const kTutorialStepRoleFilter;
extern NSString* const kTutorialStepSpotRect;
extern NSString* const kTutorialStepHoleShape;
extern NSString* const kTutorialStepTayAnywhereDismiss;
extern NSString* const kTutorialStepText;
extern NSString* const kTutorialStepSelectorString;
extern NSString* const kTutorialStepDisplayed;
extern NSString* const kTutorialStepChained;

#pragma mark - Contexts
extern NSString* const kAccountContext;
extern NSString* const kConversationContext;
extern NSString* const kFileContext;
extern NSString* const kTeamContext;
extern NSString* const kOrgContext;
extern NSString* const kPatientContext;
extern NSString* const kAlbumContext;

#pragma mark - Account
extern NSString* const kStatusKey;
extern NSString* const kLoggedInKey;
extern NSString* const kFirstNameKey;
extern NSString* const kLastNameKey;
extern NSString* const kFullNameKey;
extern NSString* const kMobileKey;
extern NSString* const kPhoneKey;
extern NSString* const kGenderKey;
extern NSString* const kShortMalePlaceholder;
extern NSString* const kShortFemalePlaceholder;
extern NSString* const kShortOtherGenderPlaceholder;
extern NSString* const kMaleString;
extern NSString* const kFemaleString;
extern NSString* const kUnspecifiedString;
extern NSString* const kAgeKey;
extern NSString* const kDOBKey;
extern NSString* const kProfileKey;
extern NSString* const kNewKey;
extern NSString* const kSpecialtyKey;
extern NSString* const kAffiliationKey;
extern NSString* const kNPIKey;
extern NSString* const kStateKey;
extern NSString* const kNumberKey;
extern NSString* const kLicenseKey;
extern NSString* const kUnverifiedKey;
extern NSString* const kVerifiedKey;
extern NSString* const kVerifyingKey;
extern NSString* const kBirthdayKey;
extern NSString* const kInvitationRequiredKey;
extern NSString* const kActivationRequiredKey;
extern NSString* const kConnectionAccessKey;
extern NSString* const kCreatedKey;
extern NSString* const kUpdatedKey;
extern NSString* const kFavoriteKey;
extern NSString* const kKeyKey;
extern NSString* const kSharedKey;
extern NSString* const kTeamsKey;
extern NSString* const kActivateKey;
extern NSString* const kVerifyKey;
extern NSString* const kPublicKey;
extern NSString* const kProviderKey;

#pragma mark - Data Encryption
extern NSString* const kClientKeyVirtual;
extern NSString* const kFingerprintKey;
extern NSString* const kSecretKey;

#pragma mark - Legal
extern NSString* const kLegalKey;
extern NSString* const kLegalTargetNoneKey;
extern NSString* const kLegalTargetAllKey;
extern NSString* const kClientKey;

#pragma mark - Server errors
extern NSString* const kMDAPIErrorNewLocation;
extern NSString* const kMDAPIErrorUnverifiedLocation;
extern NSString* const kMDAPIErrorInvalidToken;
extern NSString* const kMDAPIErrorAccountAlreadyVerified;
extern NSString* const kMDAPIErrorNotLoggedIn;
extern NSString* const kMDAPIErrorRegistrationInvitationRequired;
extern NSString* const kMDAPIErrorLocationClientMismatch;

#pragma mark - Multiple uses
extern NSString* const kIDKey;
extern NSString* const kNameKey;
extern NSString* const kFullKey;
extern NSString* const kCodeKey;
extern NSString* const kTextKey;
extern NSString* const kMessageKey;
extern NSString* const kEmailKey;
extern NSString* const kEmptyString;
extern NSString* const kPreferencesKey;
extern NSString* const kDescriptionKey;
extern NSString* const kObjectKey;
extern NSString* const kTimestampKey;
extern NSString* const kContextKey;
extern NSString* const kContextsKey;
extern NSString* const kContextIdKey;
extern NSString* const kTypeKey;
extern NSString* const kAccessKey;
extern NSString* const kConnectionsKey;
extern NSString* const kFeedKey;
extern NSString* const kInvitationsKey;
extern NSString* const kAccountsKey;
extern NSString* const kUpdatesKey;
extern NSString* const kImageKey;
extern NSString* const kGeoKey;
extern NSString* const kReasonKey;
extern NSString* const kPostKey;
extern NSString* const kPostSeqKey;
extern NSString* const kValueKey;
extern NSString* const kFromKey;
extern NSString* const kToKey;
extern NSString* const kCollaborationKey;
extern NSString* const kInvitationKey;
extern NSString* const kRevokeKey;
extern NSString* const kTestKey;
extern NSString* const kTeamIdKey;
extern NSString* const kAccountKey;
extern NSString* const kAccountIdKey;
extern NSString* const kPostIdsKey;
extern NSString* const kPostTypesKey;
extern NSString* const kStreamKey;
extern NSString* const kSegmentIdKey;
extern NSString* const kBase64Key;
extern NSString* const kLabelKey;
extern NSString* const kDefaultKey;
extern NSString* const kCommaKey;
extern NSString* const kExclamationKey;
extern NSString* const kIPhoneKey;
extern NSString* const kPlaceholder;
extern NSString* const kNPIHealthUSPreffix;
extern NSString* const kMobileUrlKey;
extern NSString* const kUrlKey;
extern NSString* const kVisibilityKey;
extern NSString* const kSearchText;
extern NSUInteger const kFeedPageSize;
extern NSUInteger const kConversationPageSize;
extern NSUInteger const kPatientPageSize;
extern NSUInteger const kFilePageSize;
extern NSUInteger const kTeamPageSize;
extern NSString* const kDiagnosesSegmentKey;
extern NSString* const kInfoKey;

#pragma mark - Keychain keys
extern NSString* const kKeichainEmailKey;

#pragma mark - Notifications
extern NSString* const kMDNotificationAPIIsNotLoggedIn;
extern NSString* const kMDNotificationAPIFingerprintAndSecretDidChange;
extern NSString* const kMDNotificationNetworkReachabilityNoInternetConnection;
extern NSString* const kMDNotificationNetworkReachabilityInternetConnectionAvailable;
extern NSString* const kMDNotificationAPIServerErrorDidOccur;
extern NSString* const kMDNotificationUserDidLogin;
extern NSString* const kMDNotificationUserDidLogout;

#pragma mark - MDNotification
extern NSString* const kNotificationContextKey;
extern NSString* const kNotificationObjectKey;
extern NSString* const kNotificationTypeKey;
extern NSString* const kNotificationMetadataKey;
extern NSString* const kMetaKey;

#pragma mark - Patient profile
extern NSString* const kPatientProfileKey;
extern NSString* const kMRNKey;
extern NSString* const kPatientIdKey;
extern NSString* const kPatientAccountIdKey;
extern NSString* const kAccountConnectedKey;

#pragma mark - Care Conversation
extern NSString* const kArchivalKey;
extern NSString* const kCreatorKey;
extern NSString* const kOwnerKey;
extern NSString* const kPatientAccountKey;
extern NSString* const kPatientFileKey;

#pragma mark - Team
extern NSString* const kMemberCountKey;

#pragma mark - Invitation
extern NSString* const kRecipientKey;
extern NSString* const kSenderKey;

#pragma mark - Post
extern NSString* const kCommentsKey;
extern NSString* const kTagsKey;
extern NSString* const kSequenceKey;
extern NSString* const kVoteKey;
extern NSString* const kVotedKey;
extern NSString* const kVotesKey;

#pragma mark - Media
extern NSString* const kImageAttachmentName;
extern NSString* const kMediaKey;
extern NSString* const kFolderKey;
extern NSString* const kImageDetail;
extern NSString* const kImageFull;
extern NSString* const kNoImageType;
extern NSString* const kImageName;
extern NSString* const kProfileImageName;
extern NSString* const kCensoredImageName;
extern NSString* const kThumbnailKey;
extern NSString* const kCountKey;
extern NSUInteger const kAlbumMediaPageSize;
extern NSString* const kMediaIdKey;
extern NSString* const kMimeKey;
extern NSString* const kImagePngFilename;
extern NSString* const kCensorPngFilename;

#pragma mark - Biogram
extern NSString* const kBiogramKey;
extern NSString* const kHeartrateKey;
extern NSString* const kIntegerKey;
