"
Client preferences are applied on startup. 
See GciSession>>postLoadClientPreferences.

Server preferences are stored in #JadeitePreferences in UserGlobals 
on the server. If the value is a block, it gets run on login after 
client preferences. See GciSession>>postLoadServerPreferences

DefaultFont & DefaultTextFont are captured lazily at startup as changing fonts
dynamically can change the system default fonts. 
"
Class {
	#name : 'JadeitePreferences',
	#superclass : 'Object',
	#instVars : [
		'session',
		'lastWindowPosition',
		'font',
		'textFont',
		'preferences'
	],
	#classVars : [
		'Current',
		'DefaultFont',
		'DefaultTextFont',
		'IsRowanLoaded',
		'ShowProgressBar'
	],
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'settings' }
JadeitePreferences class >> autocommitEnabled [

	^ self current autocommitEnabled
]

{ #category : 'settings' }
JadeitePreferences class >> autocommitEnabled: aBoolean [

	self current autocommitEnabled: aBoolean
]

{ #category : 'settings' }
JadeitePreferences class >> createShowProgressBarRow [

	^ Smalltalk ui theme newRowIn: self for: {
			  self showProgressBarCheckbox.
			  self stopProgressBarButton }
]

{ #category : 'as yet unclassified' }
JadeitePreferences class >> current [
	^Current ifNil: [ Current := JadeitePreferences new ]
]

{ #category : 'as yet unclassified' }
JadeitePreferences class >> current: aJadeitePreferences [
	self todo:[Current ifNil: [DefaultTextFont := self initializeDefaultFonts]].
	Current := aJadeitePreferences
]

{ #category : 'as yet unclassified' }
JadeitePreferences class >> defaultFont [
	^DefaultFont
]

{ #category : 'as yet unclassified' }
JadeitePreferences class >> defaultTextFont [
	^DefaultTextFont
]

{ #category : 'as yet unclassified' }
JadeitePreferences class >> displayFontFrom: newFont [
	| lfw lf |
	lf := newFont logFont.
	lfw := LOGFONTW new. "believe this is necessary if the user picks a legacy font - LOGFONTA"
	lfw
		replaceFrom: 1
		to: lf byteSize
		with: lf bytes
		startingAt: 1.
	lfw faceName: lf faceName.
	View desktop font: (Font fromLogFont: lfw)
]

{ #category : 'as yet unclassified' }
JadeitePreferences class >> initializeDefaultFonts [
	DefaultFont := SmalltalkSystem current defaultFont.
	^Font name: 'Verdana' pointSize: 10
]

{ #category : 'settings' }
JadeitePreferences class >> isRowanLoaded [ 

	^IsRowanLoaded ifNil: [ IsRowanLoaded := true ]
]

{ #category : 'settings' }
JadeitePreferences class >> isRowanLoaded: aBoolean [
	"
	IsRowanLoaded := true.
	IsRowanLoaded := false.
	"
	IsRowanLoaded := aBoolean
]

{ #category : 'as yet unclassified' }
JadeitePreferences class >> onSession: session [
	^self new session: session
]

{ #category : 'settings' }
JadeitePreferences class >> openBrowserOnClass [

	^ self current openBrowserOnClass
]

{ #category : 'settings' }
JadeitePreferences class >> openBrowserOnClass: aString [

	self current openBrowserOnClass: aString
]

{ #category : 'as yet unclassified' }
JadeitePreferences class >> preferencesFile [

	^'Jadeite.prefs'
]

{ #category : 'as yet unclassified' }
JadeitePreferences class >> preferencesFileDefaultContents [

	^ '#Remove # to uncomment option. 
#Preferences are now found in Pharo Settings Browser
#legal values are a boolean

#autocommitEnabled: false
#autocompleteEnabled: false
#breakpointsEnabled: true
#loggingEnabled: false
#transcriptEnabled: true
#packageGroupsVisible: false
#packageListVisible: true

#legal values are font name plus font point size
#font: Segoe UI 10
#textFont: Verdana 10

#legal values are a name (without quotes or angle brackets) or nil
#openBrowserOnClasses: <className1 className2 ...>
#openBrowserOnPackage: <package name>
#openBrowserOnProject: <project name> 
#openSUnitBrowserOnPackage: <package name>
#openWorkspace: <file path without quotes or nil> 
#transcriptEnabled: true
#sigAbortProcessInterval: <# of seconds with default 10>
#sigAbortsProcessEnabled: true
#transactionMode: <autoBegin manualBegin transactionless>'
		  replaceCrWithLf
]

{ #category : 'as yet unclassified' }
JadeitePreferences class >> preferencesPath [

	^ FileSystem disk workingDirectoryPath pathString , '/'
	  , self preferencesFile
]

{ #category : 'settings' }
JadeitePreferences class >> settingsOn: aBuilder [

	<systemsettings>
	(aBuilder group: #jadeiteForPharo)
		label: 'Jadeite For Pharo';
		description:
			'Settings applied when Jadeite For Pharo is initially connected to a stone';
		with: [
			(aBuilder setting: #autocommitEnabled)
				label: 'Auto Commit';
				default: false;
				description: 'Do a GemStone commit after every server interaction'.
			(aBuilder setting: #openBrowserOnClass)
				label: 'Open Browser On Class';
				default: String new;
				description:
					'After connection, open a browser on a class. To disable preference, leave class name blank.'.
			(aBuilder setting: #isRowanLoaded)
				label: 'Rowan Available';
				default: String new;
				description:
					'For GemTalk internal development. Simulate Rowan availability.'.
			(aBuilder setting: #current)
				label: 'Show Progress Bar ';
				dialog: [ self createShowProgressBarRow ] ]
]

{ #category : 'settings' }
JadeitePreferences class >> showProgressBar [

	^ ShowProgressBar ifNil: [ ShowProgressBar := true ]
]

{ #category : 'settings' }
JadeitePreferences class >> showProgressBar: aBoolean [

	ShowProgressBar := aBoolean
]

{ #category : 'settings' }
JadeitePreferences class >> showProgressBarCheckbox [

	^ Smalltalk ui theme
		  newCheckboxIn: Smalltalk ui theme
		  for: self
		  getSelected: #showProgressBar
		  setSelected: #showProgressBar:
		  getEnabled: #showProgressBarEnablement
		  label: 'Show Progress Bar'
		  help: 'Display a progress bar when Jadeite For Pharo is busy'
]

{ #category : 'settings' }
JadeitePreferences class >> showProgressBarEnablement [

	^true
]

{ #category : 'settings' }
JadeitePreferences class >> stopProgressBarButton [

	^ (Smalltalk ui theme
		   newButtonIn: self
		   for: self
		   getState: nil
		   action: nil
		   arguments: nil
		   getEnabled: nil
		   getLabel: nil
		   help:
			   'Stop any active progress bars in case they get stuck or annoying'
				   translated)
		  label: 'Stop Active Progress Bars';
		  actionBlock: [ RowanServiceUpdater current stopProgressBar ];
		  yourself
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> allowsSpacesInArgument: commandSymbol [
	^commandSymbol = #openWorkspace: or: 
			[commandSymbol = #openBrowserOnClasses: or: [commandSymbol = #font: or: [commandSymbol = #textFont:]]]
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> applicablePreferences [
	"Which inst vars are actual preferences"

	^ #( autocommitEnabled openBrowserOnClass )
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> application [
	"Spec2 needs this to open a browser via preferences"
	^JadeiteConsoleApplication new
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> applyPreference: preferencesString [
	"only perform messages which are defined by this class"

	| message subStrings |
	
	preferencesString trimBlanks substrings isEmpty ifTrue: [^self].
	subStrings := preferencesString substrings.
	message := subStrings first asSymbol.
	(self allowsSpacesInArgument: message)
		ifTrue: [^self performCommand: message allowSpacesInArgs: preferencesString].
	subStrings size = 2 ifFalse: [^self].	"single keyword argument format for now"
	message := subStrings first asSymbol.
	message first = $# ifTrue: [^self].
	(JadeitePreferences methodDictionary at: message ifAbsent: [])
		ifNotNil: [self perform: message with: preferencesString substrings second]
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> applyPreferences [

	preferences do: [ :ea | ea apply ]
]

{ #category : 'accessing' }
JadeitePreferences >> autocommitEnabled [

	| pref |
	pref := preferences at: #autocommitEnabled ifAbsentPut: [
		        JadeitePreference
			        for: #autocommitEnabled
			        action: [ :preferenceValue |
				        RowanAnsweringService new
					        setAutoCommit: preferenceValue
					        for: GciSession current ] ].
	^ pref value
]

{ #category : 'accessing' }
JadeitePreferences >> autocommitEnabled: aBoolean [

	(preferences at: #autocommitEnabled) value: aBoolean
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> autocompleteEnabled: booleanString [
	| boolean |
	boolean := booleanString = 'true'.
	GciSession current flipAutoCommit
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> breakpointsEnabled: booleanString [
	| answeringService boolean |
	boolean := booleanString = 'true'.
	answeringService := RowanAnsweringService new
				command: #setBreakPointsAreEnabled:;
				commandArgs: (Array with: boolean).
	RowanServiceUpdater current issueCommands: (Array with: answeringService) session: session onCompletion: [  ]
]

{ #category : 'copying' }
JadeitePreferences >> copy [

	| copy |
	copy := super copy.
	copy preferences: (copy preferences collect: [ :pref | pref copy ]).
	^ copy
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> currentFont [
	font ifNil: [font := self class defaultFont].
	^font
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> currentFont: anObject [
	font := anObject
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> currentTextFont [
	textFont ifNil: [textFont := self class defaultTextFont].
	^textFont
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> currentTextFont: anObject [
	textFont := anObject
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> font: stringWithFontNameSize [
	| fontInfoArray fontName |
	fontInfoArray := stringWithFontNameSize subStrings.
	fontName := (fontInfoArray copyFrom: 1 to: fontInfoArray size - 1) fold: [:a :b | a , ' ' , b].
	font := Font name: fontName pointSize: fontInfoArray last asNumber.
	self class displayFontFrom: font
]

{ #category : 'initialization' }
JadeitePreferences >> initialize [

	super initialize.
	preferences := Dictionary new 
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> loggingEnabled: booleanString [
	| boolean |
	boolean := booleanString = 'true'.
	RowanServiceUpdater current isLogging: boolean
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> openBrowser [

	| inst | 
	inst := JadeiteBrowser new owner: self. 
	inst
		application: JadeiteConsoleApplication new;
		gciSession: GciSession current. 
	inst open.
	inst addStyle: 'jadeWorkspace'.
	^inst
]

{ #category : 'accessing' }
JadeitePreferences >> openBrowserOnClass [

	| pref |
	pref := preferences at: #openBrowserOnClass ifAbsentPut: [
		        JadeitePreference
			        for: #openBrowserOnClass
			        action: [ :preferenceValue |
				        preferenceValue ifNotNil: [
					        preferenceValue isEmpty ifFalse: [
						        self openBrowser findClassNamed: preferenceValue ] ] ] ].
	^ pref value
]

{ #category : 'accessing' }
JadeitePreferences >> openBrowserOnClass: className [

	(preferences at: #openBrowserOnClass) value: className
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> openBrowserOnClasses: stringOfClassNames [

	| classNameArray |
	classNameArray := stringOfClassNames substrings.
	classNameArray do: [ :className | self openBrowserOnClass: className ].
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> openBrowserOnPackage: packageName [
	| projectBrowser |
	projectBrowser := self openBrowser.
	projectBrowser activePresenter selectPackageNamed: packageName.
	self todo:[lastWindowPosition := projectBrowser view position].
	^projectBrowser
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> openBrowserOnProject: projectName [
	| projectBrowser |
	projectBrowser := self openBrowser. 
	projectBrowser activePresenter findProjectNamed: projectName.
	self todo:[lastWindowPosition := projectBrowser view position].
	^projectBrowser
]

{ #category : 'actions' }
JadeitePreferences >> openSUnitBrowser [

	| inst |
	inst := JadeiteSUnitPresenter basicNew.
	inst
		application: self application;
		gciSession: GciSession current;
		initialize.
	inst open.
	inst addStyle: 'jadeWorkspace'.
	^inst
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> openSUnitBrowserOnPackage: packageName [
	| sunitBrowser packageSelection |
	sunitBrowser := self openSUnitBrowser.
	packageSelection := sunitBrowser packageListPresenter list
				detect: [:packageService | packageService name = packageName]
				ifNone: [^self].
	sunitBrowser packageListPresenter selection: packageSelection.
	self todo:[lastWindowPosition := sunitBrowser view position].
	^sunitBrowser
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> openWorkspace: pathOrNil [
	| workspace |
	
	(pathOrNil = 'nil' or: [ pathOrNil isEmpty ])
		ifFalse: 
			[(File exists: pathOrNil)
				ifTrue: [workspace := JadeiteWorkspace open: pathOrNil onSession: GciSession current]
				ifFalse: 
					[| localPath |
					"try the image directory"
					localPath := SessionManager current imageBase , pathOrNil.
					(File exists: localPath)
						ifTrue: [workspace openOn: localPath]
						ifFalse: 
							[workspace view close.
							^MessageBox notify: 'preferences workspace ' , pathOrNil , ' unable to be opened']]].
	^workspace
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> packageGroupsVisible: booleanString [
	"Private - file syntax - packageGroupsVisible: true"

	| boolean | 
	boolean := booleanString = 'true'.
	JadePresenter packageGroupsVisible: boolean
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> packageListVisible: booleanString [
	"Private - file syntax - packageListVisible: true"

	| boolean |
	boolean := booleanString = 'true'.
	JadePresenter packageListVisible: boolean
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> performCommand: message allowSpacesInArgs: preferencesString [
	| argument readStream |
	readStream := ReadStream on: preferencesString trimBlanks.
	readStream upTo: Character space.
	argument := readStream upToEnd.
	^self perform: message with: argument
]

{ #category : 'settings' }
JadeitePreferences >> preferenceActions [

	| actionDictionary |
	actionDictionary := Dictionary new.
	actionDictionary
		at: #autocommitEnabled
		put: [ :aBoolean | self applyAutocommitEnabled: aBoolean ].
	actionDictionary
		at: #openBrowserOnClass
		put: [ :className | self applyOpenBrowserOnClass: className ].
	^ actionDictionary
]

{ #category : 'accessing' }
JadeitePreferences >> preferences [

	^ preferences
]

{ #category : 'accessing' }
JadeitePreferences >> preferences: anObject [

	preferences := anObject
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> resetFont [
	View desktop font: JadeitePreferences defaultFont.
	font := self class defaultFont
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> root [
"Spec2 needs this to open a browser via preferences"
	^SpAbstractPresenter new
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> session: anObject [
	session := anObject
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> sigAbortProcessInterval: anIntegerString [
	JadePresenter sigAbortProcessInterval: anIntegerString asNumber
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> sigAbortsProcessEnabled: booleanString [
	JadePresenter sigAbortsProcessEnabled: booleanString = 'true'
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> transactionMode: transactionMode [
	JadePresenter transactionMode: transactionMode asSymbol session: session
]

{ #category : 'as yet unclassified' }
JadeitePreferences >> transcriptEnabled: booleanString [
	"Private - file syntax - transcriptEnabled false"

	| answeringService boolean |
	boolean := booleanString = 'true'.
	answeringService := RowanAnsweringService new.
	(answeringService isTranscriptInstalledIn: session) == boolean
		ifFalse: [answeringService flipTranscriptIn: session]
]
