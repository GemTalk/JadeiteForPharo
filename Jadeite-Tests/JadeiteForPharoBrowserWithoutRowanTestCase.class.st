Class {
	#name : 'JadeiteForPharoBrowserWithoutRowanTestCase',
	#superclass : 'JadeiteForPharoAbstractBrowserTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'coverage' }
JadeiteForPharoBrowserWithoutRowanTestCase class >> codeCoverageClasses [
	"classes that are tested by this test class.
	Code coverage tool is given these classes to monitor.
	Currently don't look at super classes"

	^ {
		  JadeiteBrowserWithoutRowan.
		  JadeiteBrowserPresenterWithoutRowan } asOrderedCollection
]

{ #category : 'support' }
JadeiteForPharoBrowserWithoutRowanTestCase >> classHierarchyServices [

	^ self classHierarchyPresenter adapter widget dataSource allShownItems
		  collect: [ :service | service data ]
]

{ #category : 'support' }
JadeiteForPharoBrowserWithoutRowanTestCase >> compileClassExpectedClassDefinition [

	^ JadeitePreferences isRowanAvailable
		  ifTrue: [ self jfp_compileClassExpectedClassDefinition ]
		  ifFalse: [ self jfpwor_compileClassExpectedClassDefinition ]
]

{ #category : 'support' }
JadeiteForPharoBrowserWithoutRowanTestCase >> createFileInFileToDisk [

	workspace := JadeiteServerFileWorkspace
		             showOnSession: session
		             path: self testFileInWorkingDirectory.
	workspace text: self fileInCode.
	workspace writeDocumentTo: self fileInFilePath.
	self destroy: workspace
]

{ #category : 'support' }
JadeiteForPharoBrowserWithoutRowanTestCase >> deleteFileInFileToDisk [

	| fileRef |
	fileRef := self fileInFilePath asFileReference.
	fileRef deleteIfAbsent: [ ]
]

{ #category : 'constants' }
JadeiteForPharoBrowserWithoutRowanTestCase >> fileInCode [

	^ 'fileformat utf8
!
! From ! GEMSTONE: 3.7.1, Wed Feb 28 12:07:47 2024 (branch 3.7.1); IMAGE: GemStone/S64 v3.7.1 kernel classes filein completed at 28/02/2024 12:26:05

! 

! On February 19, 2025, 7:40:46 PM
!
!
! SymbolDictionary ''UseSpace''
!
run
| symList newDict |
symList := System myUserProfile symbolList.
symList do: [ :element |
    (element includesKey: #UseSpace)
        ifTrue: [ ^element ]
].
newDict := SymbolDictionary new.
newDict at: #UseSpace put: newDict.
System myUserProfile insertDictionary: newDict at: 1.
^newDict
%
set compile_env: 0
! ------------------- Class definition for IPCustomerCollection
expectvalue /Class
doit
Object subclass: ''IPCustomerCollection''
  instVarNames: #( theCustomers intendedSize counter)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UseSpace
  options: #()

%
expectvalue /Class
doit
IPCustomerCollection comment: 
''No class-specific documentation for IPCustomerCollection, hierarchy is: 
Object
  IPCustomerCollection( theCustomers intendedSize)
''
%
expectvalue /Class
doit
IPCustomerCollection category: ''User Classes''
%
! ------------------- Class definition for IPCustomerCollectionHolder
expectvalue /Class
doit
Object subclass: ''IPCustomerCollectionHolder''
  instVarNames: #( theCollections)
  classVars: #()
  classInstVars: #( current)
  poolDictionaries: #()
  inDictionary: UseSpace
  options: #()

%
! ------------------- Class definition for LMApplicationObject
expectvalue /Class
doit
Object subclass: ''LMApplicationObject''
  instVarNames: #( id idString notes
                    rating startDate largeNumber smallNumber
                    longString shortString)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UseSpace
  options: #()

%
expectvalue /Class
doit
LMApplicationObject comment: 
''No class-specific documentation for LMApplicationObject, hierarchy is: 
Object
  LMApplicationObject( id idString rating startDate largeNumber smallNumber longString shortString)
''
%
expectvalue /Class
doit
LMApplicationObject category: ''User Classes''
%
! ------------------- Class definition for LMAddress
expectvalue /Class
doit
LMApplicationObject subclass: ''LMAddress''
  instVarNames: #( street city state
                    zip mediumNumber mediumString)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UseSpace
  options: #()

%
expectvalue /Class
doit
LMAddress comment: 
''No class-specific documentation for LMAddress, hierarchy is: 
Object
  LMAddress( street city zip)
''
%
expectvalue /Class
doit
LMAddress category: ''User Classes''
%
! ------------------- Class definition for LMContactInfo
expectvalue /Class
doit
LMApplicationObject subclass: ''LMContactInfo''
  instVarNames: #( address)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UseSpace
  options: #()

%
! ------------------- Class definition for LMCustomer
expectvalue /Class
doit
LMApplicationObject subclass: ''LMCustomer''
  instVarNames: #( customerName contactInfo orders)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UseSpace
  options: #()

%
expectvalue /Class
doit
LMCustomer comment: 
''No class-specific documentation for LMCustomer, hierarchy is: 
Object
  LMCustomer( customerName customerId address orders)
''
%
expectvalue /Class
doit
LMCustomer category: ''User Classes''
%
! ------------------- Class definition for LMStreetAddress
expectvalue /Class
doit
LMApplicationObject subclass: ''LMStreetAddress''
  instVarNames: #( streetNumber streetName)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UseSpace
  options: #()

%
expectvalue /Class
doit
LMStreetAddress comment: 
''No class-specific documentation for LMStreetAddress, hierarchy is: 
Object
  LMStreetAddress( streetNumber streetName apartmentNumber)
''
%
expectvalue /Class
doit
LMStreetAddress category: ''User Classes''
%
! ------------------- Class definition for NonRandom
expectvalue /Class
doit
Object subclass: ''NonRandom''
  instVarNames: #()
  classVars: #( MyRandom)
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UseSpace
  options: #()

%
expectvalue /Class
doit
NonRandom comment: 
''No class-specific documentation for NonRandom, hierarchy is: 
Object
  NonRandom
''
%
expectvalue /Class
doit
NonRandom category: ''User Classes''
%
! ------------------- Class definition for UsSpaceUser
expectvalue /Class
doit
Object subclass: ''UsSpaceUser''
  instVarNames: #()
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UseSpace
  options: #()

%

! ------------------- Remove existing behavior from IPCustomerCollection
removeallmethods IPCustomerCollection
removeallclassmethods IPCustomerCollection
! ------------------- Class methods for IPCustomerCollection
category: ''Constants''
classmethod: IPCustomerCollection
maxDateDiff
	^365
%
category: ''Constants''
classmethod: IPCustomerCollection
maxFloat
	^ 100.0
%
category: ''Constants''
classmethod: IPCustomerCollection
maxInt

	^ 10000000000000000
%
category: ''Constants''
classmethod: IPCustomerCollection
maxIntHigh
	"limit based on random generation max 32-bit int"
	^ 4294967296
%
category: ''Constants''
classmethod: IPCustomerCollection
maxIntLow

	^ 500
%
category: ''Constants''
classmethod: IPCustomerCollection
maxIntMedium

	^ 800000
%
category: ''Instance Creation''
classmethod: IPCustomerCollection
createForSize: collSz
	"(IPCustomerCollection createForSize: 1000) fillWithCustomers; yourself"

	^self createForSize: collSz class: RcIdentityBag
%
category: ''Instance Creation''
classmethod: IPCustomerCollection
createForSize: collSz class: collectionClass
	"(IPCustomerCollection createForSize: 1000) fillWithCustomers; yourself"

	| n |
	n := self new.
	n theCustomers: collectionClass new.
	n intendedSize: collSz.
	GsEventLog logTrace: ''Create customer collection of class '', collectionClass asString.
	^n
%
! ------------------- Instance methods for IPCustomerCollection
category: ''Accessing''
method: IPCustomerCollection
intendedSize
	^intendedSize
%
category: ''Accessing''
method: IPCustomerCollection
theCustomers
	^theCustomers
%
category: ''Collection''
method: IPCustomerCollection
setCollectionClass: aCollectionClass
	self theCustomers class = aCollectionClass ifTrue: [^self].
	self theCustomers: (aCollectionClass withAll: self theCustomers).
%
category: ''Collection''
method: IPCustomerCollection
size
	^theCustomers size
%
category: ''Operations''
method: IPCustomerCollection
addOneCustomer
	"make sure the collection is filled to its intended size, but no larger."
	"GsEventLog current report."

	self theCustomers add: (LMCustomer createSampleId: self counter).

%
category: ''Operations''
method: IPCustomerCollection
counter

	counter isNil ifTrue: [counter := 0].
	counter := counter + 1.
	^counter
%
category: ''Operations''
method: IPCustomerCollection
fillWithCustomers
	"make sure the collection is filled to its intended size, but no larger."
	"GsEventLog current report."

	GsFile gciLogServer: ''Filling collection with customers, currently '',  self theCustomers size asString, '' filling to '', self intendedSize asString.
	1 to: (self intendedSize - self theCustomers size) do: [:i |
		self theCustomers add: (LMCustomer createSampleId: self counter).
		(i \\ 20000) = 0 ifTrue: [GsFile gciLogServer: ''...added 20000 customers.''.].
		(i \\ 10000) = 0 ifTrue: [
			| res |	
			res := System commitTransaction.
			res 
				ifTrue: [GsEventLog logTrace: ''commit'']
				ifFalse: [System abort. GsEventLog logTrace: ''commit failed; aborting''].
			].
		].


%
category: ''Operations''
method: IPCustomerCollection
fillWithCustomers: num
	"we allow filling partway so we can distribute oops 
	of newly created objects between collections"

	| toAdd |
	GsFile gciLogServer: ''Filling collection with '', num asString, '' customers, currently '',  self theCustomers size asString, '' filling to '', self intendedSize asString.

	self theCustomers size >= self intendedSize
		ifTrue: [^self].
	
	toAdd := (self intendedSize - self theCustomers size) min: num.
	1 to: toAdd do: [:i |
		self theCustomers add: (LMCustomer createSampleId: self counter).
		(i \\ 10000) = 0 ifTrue: [
			| res |	
			res := System commitTransaction.
			res 
				ifTrue: [GsEventLog logTrace: ''  Added 10000 customers; commit'']
				ifFalse: [System abort. GsEventLog logTrace: ''commit failed; aborting''].
			].
		].



%
category: ''Operations''
method: IPCustomerCollection
fillWithCustomersToAddMB: aSize
	"(IPCustomerCollection createForSize: 10000) fillWithOneMBOfCustomers"

	| added free size used perCount res |
	used := self usedSpaceMb.
	added := 0.
	1 to: 1000000 by: 2 do: [:i |
		self theCustomers add: (LMCustomer createSampleId: self counter).
		self theCustomers add: (LMCustomer createSampleId: self counter + 1).
		(System commitTransaction)
			ifTrue: [added := added + 2]
			ifFalse: [System abort].
		size := self usedSpaceMb.
		size - free > used ifTrue: [^added].
		].
	^''1000000 was not enough''


%
category: ''Operations''
method: IPCustomerCollection
fillWithCustomersToUseMb: maxMb
	"make sure the collection is filled with enough customers to use up to maxMB size. "
	"(IPCustomerCollection createForSize: 100000) fillWithCustomersToUseMb: 4"

	| used perCount orig added |
	orig := self theCustomers size.
	perCount := self fillWithOneMBOfCustomers.
	used := self usedSpaceMb.
	GsEventLog logTrace: ''Filling collection with customers...''.

	1 to: (maxMb * perCount) - 2 do: [:i |
		self theCustomers add: (LMCustomer createSampleId: self counter).
		(i \\ 20000) = 0 ifTrue: [GsEventLog logTrace: ''...added 20000 customers.''.].
		(i \\ 10000) = 0 ifTrue: [
			| res |	
			res := System commitTransaction.
			res 
				ifTrue: [GsEventLog logTrace: ''commit'']
				ifFalse: [System abort. GsEventLog logTrace: ''commit failed; aborting''].
			].
		].
	
	perCount timesRepeat: [
		self theCustomers add: (LMCustomer createSampleId: self counter).
		System commit.
		((added := self usedSpaceMb - used) > maxMb) ifTrue: [self error: ''went over: '', added asString].
		(self usedSpaceMb - used) >= maxMb ifTrue: [^ self theCustomers size - orig].
		].

	^''used space is '', (self usedSpaceMb - used) asString.








%
category: ''Operations''
method: IPCustomerCollection
fillWithOneMBOfCustomers
	"(IPCustomerCollection createForSize: 10000) fillWithOneMBOfCustomers"

	| free size used perCount |
	size := (System stoneCacheStatisticWithName: ''ReposSizeMB'').
	free := (((System stoneCacheStatisticWithName: ''FreePages'') * 16384) / 1024000) asInteger.
	used := size - free.

	1 to: 10000 do: [:i |
		self theCustomers add: (LMCustomer createSampleId: self counter).
		System commit.
		size := (System stoneCacheStatisticWithName: ''ReposSizeMB'').
		free := (((System stoneCacheStatisticWithName: ''FreePages'') * 16384) / 1024000) asInteger.
		size - free > used ifTrue: [^i].
		].
	^''10000 was not enough''


%
category: ''Operations''
method: IPCustomerCollection
removeOneCustomer
	"make sure the collection is filled to its intended size, but no larger."
	"GsEventLog current report."
	
	self theCustomers do: [:ea | 
		self theCustomers remove: ea.
		^self
		].

%
category: ''Operations''
method: IPCustomerCollection
usedSpaceMb
	| size free |
	size := (System stoneCacheStatisticWithName: ''ReposSizeMB'').
	free := (((System stoneCacheStatisticWithName: ''FreePages'') * 16384) / 1024000) asInteger.
	^size - free.
%
category: ''Updating''
method: IPCustomerCollection
intendedSize: newValue
	intendedSize := newValue
%
category: ''Updating''
method: IPCustomerCollection
theCustomers: newValue
	theCustomers := newValue
%

! ------------------- Remove existing behavior from IPCustomerCollectionHolder
removeallmethods IPCustomerCollectionHolder
removeallclassmethods IPCustomerCollectionHolder
! ------------------- Class methods for IPCustomerCollectionHolder
category: ''Fill with data''
classmethod: IPCustomerCollectionHolder
deleteSomeData
	"IPCustomerCollectionHolder deleteSomeData"

	| used |
	self current theCollections at: 2 put: (IPCustomerCollection createForSize: 200).
%
category: ''Fill with data''
classmethod: IPCustomerCollectionHolder
deleteSomeDataGcAndWait: waits
	"IPCustomerCollectionHolder deleteSomeDataGcAndWait: 20"
 
	| free secs | 
	secs := Time now asSeconds. 
	free := self freePagesMB.
	GsFile gciLogServer: self report.
	self current theCollections at: 2 put: (IPCustomerCollection createForSize: 200).
	System commit.
	SystemRepository markForCollection.
	GsFile gciLogServer: SystemRepository markForCollection printString.
	GsFile gciLogServer: self report.
	20 timesRepeat: [
		System sleep: 1.
		System abort.
		].

	(waits - 20) timesRepeat: [
		System sleep: 1.
		System abort.
		(self freePagesMB > free) ifTrue: [^''FreePages has gone from '', free asString, '' to '', self freePagesMB asString, '' in '',  (Time now asSeconds - secs) asString, '' seconds''. ].
		].

	^''Failed: free pages has not increased after '', (Time now asSeconds - secs) asString, '' seconds. FreePages has gone from '', free asString, '' to '', self freePagesMB asString.

	
	
%
category: ''Fill with data''
classmethod: IPCustomerCollectionHolder
doGC
	System commit.
	SystemRepository markForCollection.
	System abort.
	1000 timesRepeat: [].

%
category: ''Fill with data''
classmethod: IPCustomerCollectionHolder
fillWithCustomers: numCustomers
	"This assumes the collections were already created.
	Fill each collection with the same percent of customers.
	Do the fill in four chunks to distribute oops.
	This is not intended to run in parallel with any other work, so takes credit for the entire count diff"

	"IPCustomerCollectionHolder setupCollections. IPCustomerCollectionHolder fillWithCustomers: 1000000. "

	| ct origSize goalSize setSize added numCollections |
	origSize := self current totalCustomers.
	goalSize := origSize + numCustomers.
	numCollections :=  IPCustomerCollectionHolder current theCollections size.
	setSize := ( (numCustomers / 4)  / numCollections ) asInteger - 1. 
	added := 0.
	4 timesRepeat: [
		self doInExternalSession: ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers: '', setSize asString, ''].''.].
 	ct := 0.
	[ct < 10000] whileTrue: [
		self current totalCustomers >= goalSize ifTrue: [^self current totalCustomers - origSize].
		(IPCustomerCollectionHolder current theCollections at: (numCollections \\ ct) + 1) addOneCustomer.
		ct := ct + 1
		].

	^self current totalCustomers - origSize

%
category: ''Fill with data''
classmethod: IPCustomerCollectionHolder
fillWithData
	"IPCustomerCollectionHolder initialize. IPCustomerCollectionHolder fillWithData. "
	| used |
	used := self usedSpaceMb.
	self current theCollections add: (IPCustomerCollection createForSize:  4000).
	self current theCollections add: (IPCustomerCollection createForSize: 20000).
	self current theCollections add: (IPCustomerCollection createForSize: 14000).

	self doInExternalSession: ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers: 10000].''.
	self doInExternalSession: ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers: 50000].''.
	self doInExternalSession: ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers].''.
	^self usedSpaceMb - used

%
category: ''Fill with data''
classmethod: IPCustomerCollectionHolder
fillWithDataLarge
	"IPCustomerCollectionHolder initialize. IPCustomerCollectionHolder fillWithDataLarge. "
	| used |
	used := self usedSpaceMb.
	self current theCollections add: (IPCustomerCollection createForSize: 300000).
	self current theCollections add: (IPCustomerCollection createForSize: 300000).
	self current theCollections add: (IPCustomerCollection createForSize: 300000).
	self current theCollections add: (IPCustomerCollection createForSize: 300000).

	self doInExternalSession: ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers: 100000].''.
	self doInExternalSession: ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers: 100000].''.
	self doInExternalSession: ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers].''.
	^self usedSpaceMb - used

%
category: ''Fill with data''
classmethod: IPCustomerCollectionHolder
fillWithDataMedium
	"IPCustomerCollectionHolder initialize. IPCustomerCollectionHolder fillWithDataMedium. "
	| used |
	used := self usedSpaceMb.
	self current theCollections add: (IPCustomerCollection createForSize: 100000).
	self current theCollections add: (IPCustomerCollection createForSize: 30000).
	self current theCollections add: (IPCustomerCollection createForSize: 300000).


	self doInExternalSession: ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers: 100000].''.
	self doInExternalSession: ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers: 100000].''.
	self doInExternalSession: ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers].''.
	^self usedSpaceMb - used

%
category: ''Fill with data''
classmethod: IPCustomerCollectionHolder
keepLightlyBusyFor: minsToWork
	" with a 10 second sleepDuration, the loop should take about a minute"

	| thisSet startTime endTime changesPerRun totalChanges sleepDuration usedSeconds  |
	startTime := Time now asSeconds.
	endTime := minsToWork * 60.
	totalChanges := 0.
	sleepDuration := 10.  "seconds, 10 ms between aborts"

	[usedSeconds := Time now asSeconds - startTime.
	GsFile gciLogServer: ''worked for '', usedSeconds asString, '' seconds, total '', totalChanges asString, '' changes made''.
	usedSeconds > endTime ] whileFalse: 
		[
		IPCustomerCollectionHolder current theCollections do: [:ea | 
			ea removeOneCustomer. totalChanges := totalChanges + 1.
			sleepDuration * 100 timesRepeat: [System _sleepMs: 10. System abort].
			System commitTransaction ifFalse: [GsFile gciLogServer: ''Commit failed; change size reports may be wrong''. System abort].

			UserGlobals at: #now put: DateTime now.
			System commitTransaction ifFalse: [GsFile gciLogServer: ''Commit failed; change size reports may be wrong''. System abort].
			sleepDuration * 100  timesRepeat: [System _sleepMs: 10. System abort].

			ea addOneCustomer. totalChanges := totalChanges + 1.
			System commitTransaction ifFalse: [GsFile gciLogServer: ''Commit failed; change size reports may be wrong''. System abort].
			sleepDuration * 100  timesRepeat: [System _sleepMs: 10. System abort].

			UserGlobals at: #now put: DateTime now.
			System commitTransaction ifFalse: [GsFile gciLogServer: ''Commit failed; change size reports may be wrong''. System abort].
			sleepDuration * 100  timesRepeat: [System _sleepMs: 10. System abort].

			UserGlobals at: #now put: DateTime now.
			System commitTransaction ifFalse: [GsFile gciLogServer: ''Commit failed; change size reports may be wrong''. System abort].
			sleepDuration * 100  timesRepeat: [System _sleepMs: 10. System abort].
			].
		].
	^totalChanges asString, '' elements updated in '', minsToWork asString, '' minutes''
%
category: ''Fill with data''
classmethod: IPCustomerCollectionHolder
makeUpdatesFor: minsToWork withMFCs: secs
	"IPCustomerCollectionHolder makeUpdatesFor: 5"

	| thisSet startTime endTime changesPerRun totalChanges start end usedSeconds maxId timeOfMFC |
	startTime := Time now asSeconds.
	endTime := minsToWork * 60.
	changesPerRun := 5000.
	totalChanges := 0.

	maxId := IPCustomerCollectionHolder current theCollections first size.
	2 to: IPCustomerCollectionHolder current theCollections size do: [:i | | sz |
		(sz := IPCustomerCollectionHolder current theCollections size) > maxId ifTrue: [maxId := sz]].
	maxId := maxId - 100.
	System commit. SystemRepository markForCollection.  timeOfMFC := Time now asSeconds - startTime.

	[start := NonRandom randomBetween: 1 and: maxId.
	end := start + 2000.
	usedSeconds := Time now asSeconds - startTime.
	GsFile gciLogServer: ''worked for '', usedSeconds asString, '' seconds, total '', totalChanges asString, '' changes made''.
	usedSeconds > endTime ] whileFalse: 
		[
		GsFile gciLogServer: ''Starting batch of updates with ids starting at '', start asString.
		IPCustomerCollectionHolder current theCollections do: [:ea | | chgs |
			thisSet := ea theCustomers select: {:ea | (ea.id > start) & (ea.id < end)}.
			chgs := self makeUpdatesToCountElements: changesPerRun in: thisSet.
			ea removeOneCustomer. ea addOneCustomer.
			System commitTransaction ifFalse: [GsFile gciLogServer: ''Commit failed; change size reports may be wrong''. System abortTransaction].
			totalChanges := totalChanges + chgs + 2.	
			].
		(timeOfMFC + secs) < Time now asSeconds
			ifTrue: [GsFile gciLogServer: ''starting MFC at '', DateTime now US24HrFormat, '' lastMFC time: '' , timeOfMFC asString, '' now: '',  Time now asSeconds asString.
					SystemRepository markForCollection.  timeOfMFC := Time now asSeconds].
		].
	^totalChanges asString, '' elements updated in '', minsToWork asString, '' minutes''
%
category: ''Fill with data''
classmethod: IPCustomerCollectionHolder
report
	| str |
	str := String new.
	self current theCollections do: [:ea | str add: ''Collection with '', ea size asString; lf].
	str add: ''Repository free space is '', self freePagesMB asString; lf.
	^str
%
category: ''Fill with data''
classmethod: IPCustomerCollectionHolder
runTest
	"
	exec IPCustomerCollectionHolder initialize. IPCustomerCollectionHolder fillWithData.%
	exec IPCustomerCollectionHolder deleteSomeDataGcAndWait: 30. %
"
	
%
category: ''Fill with data''
classmethod: IPCustomerCollectionHolder
setupCollections: size
	"IPCustomerCollectionHolder initialize. IPCustomerCollectionHolder setupCollections: 300000. "
	self initialize.
	self current theCollections add: (IPCustomerCollection createForSize: size).
	self current theCollections add: (IPCustomerCollection createForSize: size).
	self current theCollections add: (IPCustomerCollection createForSize: size).
	self current theCollections add: (IPCustomerCollection createForSize: size).


%
category: ''Initialization''
classmethod: IPCustomerCollectionHolder
current
	"IPCustomerCollectionHolder initialize."
	"IPCustomerCollectionHolder fillWithData."
	^current
%
category: ''Initialization''
classmethod: IPCustomerCollectionHolder
freePagesMB
	^(((System stoneCacheStatisticWithName: ''FreePages'') * 16384) / 1024000) asInteger.

%
category: ''Initialization''
classmethod: IPCustomerCollectionHolder
initialize
	current := self new.
	current theCollections: Array new.
%
category: ''Initialization''
classmethod: IPCustomerCollectionHolder
longString
^''# STN_STATMONITOR_ARGS
#
# A list of lists of arguments used to start one or more statmonitor
# processes. If the list is not an empty string, one statmonitor process
# for each element in the list will be automatically started by the stone
# at startup time.
#
# The list of possible statmonitor arguments may be obtained by invoking
# statmonitor with only the "-h" argument. The name of the stone argument to
# statmonitor is passed automatically and must not be included here. The
# -X statmonitor argument is not allowed and statmonitor will not be
# started if -X is detected.
#
# A maximum of 64 argument lists may be specified. Each argument list
# must contain between 2 and 1023 characters. List elements must be
# contained within double quotes and separated by commas.
#
# Example: start two statmonitor processes, the first with a 10 second
#          sample interval and the second with a 60 second sample
#          interval. Both processes place a date and timestamp in the output
#          file name and place the output file in the directory
#          $GEMSTONE/data:
#
# STN_STATMONITOR_ARGS =
#
# Default: "" (Statmonitor will not be started)
#STN_STATMONITOR_ARGS = "";

#=========================================================================
# STN_STONE_CACHE_STARTUP_TIMEOUT
#
#  Time in seconds allowed for the startup of the shared cache on the 
#  stone machine. This is time from when the stone forks the page cache
#  monitor process until it is able to complete its connection to that 
#  process.
#
#  The configured value may be overridden for large caches,
#  If cache is 32GB or larger, the actual minimum timeout will be 120
#  seconds, scaling up to 5 minutes for a 300GB cache.
#  For caches less than 32GB, small configured values may also
#  be overriden.
#
#  Default: 60  Min: 10 Max: 1800
#STN_STONE_CACHE_STARTUP_TIMEOUT = 60;

#=========================================================================
# STN_SYMBOL_GC_ENABLED
#
#  Determines if symbol garbage collection is allowed to run on the system
#  Setting this value to true enables symbol garbage collection.
# 
#  Runtime equivalent: #StnSymbolGcEnabled
#    (requires GarbageCollection privilege)
# Default: FALSE
#STN_SYMBOL_GC_ENABLED = FALSE;

#=========================================================================
# STN_SYMBOL_GEM_TEMPOBJ_CACHE_SIZE
#
#  Temporary object memory size of the Symbol Gem .
#
#  Runtime equivalent: #StnSymbolGemTocSize   .
#  StnSymbolGemTocSize is initialized from STN_SYMBOL_GEM_TEMPOBJ_CACHE_SIZE
#  at stone startup. If the Symbol Gem dies other than from an explicit
#  execution of   System stopSymbolGem,  then the first auto restart since
#  the latter of stone startup or runtime change to StnSymbolGemTocSize
#  will double the value of StnSymbolGemTocSize .
#
#  If repository conversion is detected at stone startup (startstone -C)
#  the default is 200MB .
#
# Default units: KB. Suffixes KB, MB, GB may be used to specify units.
# Default: 20MB Min: 10000KB Max: 10GB .
#STN_SYMBOL_GEM_TEMPOBJ_CACHE_SIZE = 20MB ;

#=========================================================================
# STN_TRAN_FULL_LOGGING
#    If TRUE, all transactions are logged, and log files are not deleted
#  by the system. If an element in STN_TRAN_LOG_DIRECTORIES is a raw partition,
#  the contents of that partition must be copied to a file system with
#  copydbf and the partition erased with removedbf before that element of
#  STN_TRAN_LOG_DIRECTORIES is needed again. Likewise, log files must
#  be moved out of directories within STN_TRAN_LOG_DIRECTORIES to
#  prevent file systems from filling up.
#
#    If FALSE, only transactions smaller than STN_TRAN_LOG_LIMIT are logged; 
#  larger transactions become checkpoints, and log files are deleted by
#  the system when the circular list of log directories wraps around.
#
#  Once stone has been started on a repository with 
#      STN_TRAN_FULL_LOGGING = TRUE, then the TRUE state
#  will persist in the repository and subsequent changes to this parameter
#  in the config file will be ignored. To change the repository back to
#  partial logging you must do a full backup and then restore the backup into
#  a copy of $GEMSTONE/bin/extent0.dbf .
#
# There is no default value.
# An explicit value of TRUE is provided at the end of this file.''
%
category: ''Initialization''
classmethod: IPCustomerCollectionHolder
usedSpaceMb
	| size free |
	size := (System stoneCacheStatisticWithName: ''ReposSizeMB'').
	free := (((System stoneCacheStatisticWithName: ''FreePages'') * 16384) / 1024000) asInteger.
	^size - free.
%
category: ''Moved to UsSpaceUser''
classmethod: IPCustomerCollectionHolder
makeUpdatesFor: minsToWork
	"IPCustomerCollectionHolder makeUpdatesFor: 5"

	| thisSet startTime endTime changesPerRun totalChanges start end usedSeconds maxId |
	startTime := Time now asSeconds.
	endTime := minsToWork * 60.
	changesPerRun := 5000.
	totalChanges := 0.

	maxId := IPCustomerCollectionHolder current theCollections first size.
	2 to: IPCustomerCollectionHolder current theCollections size do: [:i | | sz |
		(sz := IPCustomerCollectionHolder current theCollections size) > maxId ifTrue: [maxId := sz]].
	maxId := maxId - 100.

	[start := NonRandom randomBetween: 1 and: maxId.
	end := start + 2000.
	usedSeconds := Time now asSeconds - startTime.
	GsFile gciLogServer: ''worked for '', usedSeconds asString, '' seconds, total '', totalChanges asString, '' changes made''.
	usedSeconds > endTime ] whileFalse: 
		[
		GsFile gciLogServer: ''Starting batch of updates with ids starting at '', start asString.
		IPCustomerCollectionHolder current theCollections do: [:ea | | chgs |
			thisSet := ea theCustomers select: {:ea | (ea.id > start) & (ea.id < end)}.
			chgs := self makeUpdatesToCountElements: changesPerRun in: thisSet.
			ea removeOneCustomer. ea addOneCustomer.
			System commitTransaction ifFalse: [GsFile gciLogServer: ''Commit failed; change size reports may be wrong''. System abortTransaction].
			totalChanges := totalChanges + chgs + 2.	
			].
		].
	^totalChanges asString, '' elements updated in '', minsToWork asString, '' minutes''
%
category: ''Moved to UsSpaceUser''
classmethod: IPCustomerCollectionHolder
makeUpdatesToCountElements: num in: aCollection
 	| ctr |
	ctr := 0.

	aCollection do: 
		[:aCustomer |
		aCustomer longString: (self longString, self longString).
		aCustomer contactInfo address mediumString: self longString copy.
		aCustomer contactInfo address street: (LMStreetAddress createSampleId: aCustomer id).
		ctr := ctr + 1.
		ctr > num ifTrue: [ 
			System commitTransaction ifFalse: [GsFile gciLogServer: ''Commit failed; change size reports may be wrong''. System abortTransaction].
			GsFile gciLogServer: ''completed a batch of updates''.
			^ctr].
		ctr > 5000 ifTrue: [	System commitTransaction ifFalse: [GsFile gciLogServer: ''Commit failed; change size reports may be wrong''. System abortTransaction].].
		].
 
	System commit. 
	^ctr

			
%
category: ''Operations''
classmethod: IPCustomerCollectionHolder
doInExternalSession: aString

	| s1 result  |
	System commitTransaction.
	GsFile gciLogClient: (aString copyFrom: 1 to: (100 min: aString size)).
	s1 := GsTsExternalSession newDefault.
	s1 login.
	result := s1 executeString: aString.
	s1 logout.
	^result
%
! ------------------- Instance methods for IPCustomerCollectionHolder
category: ''Accessing''
method: IPCustomerCollectionHolder
theCollections
	^theCollections
%
category: ''Operations''
method: IPCustomerCollectionHolder
totalCustomers
	| sum |
	sum := 0.
	self theCollections do: [:ea |
		sum := sum + ea theCustomers size].
	^sum
%
category: ''Updating''
method: IPCustomerCollectionHolder
theCollections: newValue
	theCollections := newValue
%

! ------------------- Remove existing behavior from LMApplicationObject
removeallmethods LMApplicationObject
removeallclassmethods LMApplicationObject
! ------------------- Class methods for LMApplicationObject
category: ''Instance Creation''
classmethod: LMApplicationObject
createSampleId: idNum
	"LMApplicationObject createSampleId: 123 "
	| n |
	n := self new.
	n id: idNum.
	n idString: (self stringFor: idNum).
	n notes: (NonRandom generateString: 8).
	n startDate: (NonRandom  
			randomDateBetween: (Date today subtractDays: self maxDateDiff) 
			and: Date today ). 
	n rating: (NonRandom 
			randomFloatBetween: 0 
			and: self maxFloat asInteger).
	n largeNumber: (NonRandom randomIntegerBetween: 0 and: self maxIntHigh).
	n smallNumber: (NonRandom randomIntegerBetween: 0 and: self maxIntLow).
	n longString: (NonRandom generateString: self longStringSize). 
	n shortString: (NonRandom randomString3 ).
	^n
%
category: ''Instance Creation''
classmethod: LMApplicationObject
longStringSize
	^500
%
category: ''Instance Creation''
classmethod: LMApplicationObject
maxDateDiff	
	^IPCustomerCollection maxDateDiff
%
category: ''Instance Creation''
classmethod: LMApplicationObject
maxFloat
	^IPCustomerCollection maxFloat
%
category: ''Instance Creation''
classmethod: LMApplicationObject
maxIntHigh
	^IPCustomerCollection maxIntHigh
%
category: ''Instance Creation''
classmethod: LMApplicationObject
maxIntLow
	^IPCustomerCollection maxIntLow
%
category: ''Instance Creation''
classmethod: LMApplicationObject
shortStringSize
	^3
%
category: ''Instance Creation''
classmethod: LMApplicationObject
stringFor: idNum
	"LMApplicationObject stringEightFor: 123234234234"
	| value |
	value := ''0000000000'', idNum asString.
	^value copyFrom: (value size - 7) to: value size.

%
! ------------------- Instance methods for LMApplicationObject
category: ''Accessing''
method: LMApplicationObject
id
	^id
%
category: ''Accessing''
method: LMApplicationObject
idString
	^idString
%
category: ''Accessing''
method: LMApplicationObject
largeNumber
	^largeNumber
%
category: ''Accessing''
method: LMApplicationObject
longString
	^longString
%
category: ''Accessing''
method: LMApplicationObject
notes
	^notes
%
category: ''Accessing''
method: LMApplicationObject
rating
	^rating
%
category: ''Accessing''
method: LMApplicationObject
shortString
	^shortString
%
category: ''Accessing''
method: LMApplicationObject
smallNumber
	^smallNumber
%
category: ''Accessing''
method: LMApplicationObject
startDate
	^startDate
%
category: ''Updating''
method: LMApplicationObject
id: newValue
	id := newValue
%
category: ''Updating''
method: LMApplicationObject
idString: newValue
	idString := newValue
%
category: ''Updating''
method: LMApplicationObject
largeNumber: newValue
	largeNumber := newValue
%
category: ''Updating''
method: LMApplicationObject
longString: newValue
	longString := newValue
%
category: ''Updating''
method: LMApplicationObject
notes: newValue
	notes := newValue
%
category: ''Updating''
method: LMApplicationObject
rating: newValue
	rating := newValue
%
category: ''Updating''
method: LMApplicationObject
shortString: newValue
	shortString := newValue
%
category: ''Updating''
method: LMApplicationObject
smallNumber: newValue
	smallNumber := newValue
%
category: ''Updating''
method: LMApplicationObject
startDate: newValue
	startDate := newValue
%

! ------------------- Remove existing behavior from LMAddress
removeallmethods LMAddress
removeallclassmethods LMAddress
! ------------------- Class methods for LMAddress
category: ''Instance creation''
classmethod: LMAddress
createSampleId: idNum
	| n |
	n := super createSampleId: idNum.
	n street: (LMStreetAddress createSampleId: idNum).
	n city: (NonRandom generateString: 8).
	^n
%
! ------------------- Instance methods for LMAddress
category: ''Accessing''
method: LMAddress
city
	^city
%
category: ''Accessing''
method: LMAddress
mediumNumber
	^mediumNumber
%
category: ''Accessing''
method: LMAddress
mediumString
	^mediumString
%
category: ''Accessing''
method: LMAddress
state
	^state
%
category: ''Accessing''
method: LMAddress
street
	^street
%
category: ''Accessing''
method: LMAddress
zip
	^zip
%
category: ''Operations''
method: LMAddress
printOn: aStream
	self street printOn: aStream.
	aStream nextPutAll: '', ''.
	aStream nextPutAll: self city asString.
	aStream nextPutAll: '', ''.
	aStream nextPutAll: self state asString.
	
%
category: ''Size''
method: LMAddress
totalSize
	| runningSize |
	runningSize := self _primitiveSize.
	runningSize := runningSize + (idString size).
	runningSize := runningSize + (notes size).
	runningSize := runningSize + (startDate size).
	runningSize := runningSize + (longString size).
	runningSize := runningSize + (shortString size).
	runningSize := runningSize + (street totalSize).
	runningSize := runningSize + (city size).
	runningSize := runningSize + (state size).
	runningSize := runningSize + (zip size).
	runningSize := runningSize + (mediumString size).

	^runningSize
	 
%
category: ''Updating''
method: LMAddress
city: newValue
	city := newValue
%
category: ''Updating''
method: LMAddress
mediumNumber: newValue
	mediumNumber := newValue
%
category: ''Updating''
method: LMAddress
mediumString: newValue
	mediumString := newValue
%
category: ''Updating''
method: LMAddress
state: newValue
	state := newValue
%
category: ''Updating''
method: LMAddress
street: newValue
	street := newValue
%
category: ''Updating''
method: LMAddress
zip: newValue
	zip := newValue
%

! ------------------- Remove existing behavior from LMContactInfo
removeallmethods LMContactInfo
removeallclassmethods LMContactInfo
! ------------------- Class methods for LMContactInfo
category: ''Instance creation''
classmethod: LMContactInfo
createSampleId: idNum
	| n |
	n := super createSampleId: idNum.
	n address: (LMAddress createSampleId: idNum).
	^n
%
! ------------------- Instance methods for LMContactInfo
category: ''Accessing''
method: LMContactInfo
address
	^address
%
category: ''Size''
method: LMContactInfo
totalSize
	| runningSize |
	runningSize := self _primitiveSize.
	runningSize := runningSize + (idString size).
	runningSize := runningSize + (notes size).
	runningSize := runningSize + (startDate size).
	runningSize := runningSize + (longString size).
	runningSize := runningSize + (shortString size).
	runningSize := runningSize + (address totalSize).
	^runningSize
	 
%
category: ''Updating''
method: LMContactInfo
address: newValue
	address := newValue
%

! ------------------- Remove existing behavior from LMCustomer
removeallmethods LMCustomer
removeallclassmethods LMCustomer
! ------------------- Class methods for LMCustomer
category: ''instance creation''
classmethod: LMCustomer
createSampleId: idNum
	"LMCustomer createSampleId: 123"
	| n |
	n := super createSampleId: idNum.
	n contactInfo: (LMContactInfo createSampleId: idNum).
	^n
%
! ------------------- Instance methods for LMCustomer
category: ''Accessing''
method: LMCustomer
contactInfo
	^contactInfo
%
category: ''Accessing''
method: LMCustomer
customerName
	^customerName
%
category: ''Accessing''
method: LMCustomer
orders
	^orders
%
category: ''calculateSize''
method: LMCustomer
totalSize
	| runningSize |
	runningSize := self _primitiveSize.
	runningSize := runningSize + (idString size).
	runningSize := runningSize + (notes size).
	runningSize := runningSize + (startDate size).
	runningSize := runningSize + (longString size).
	runningSize := runningSize + (shortString size).
	runningSize := runningSize + (customerName size).
	runningSize := runningSize + (contactInfo totalSize).
	runningSize := runningSize + (orders size).
	^runningSize
	 
	
%
category: ''Updating''
method: LMCustomer
contactInfo: newValue
	contactInfo := newValue
%
category: ''Updating''
method: LMCustomer
customerName: newValue
	customerName := newValue
%
category: ''Updating''
method: LMCustomer
orders: newValue
	orders := newValue
%

! ------------------- Remove existing behavior from LMStreetAddress
removeallmethods LMStreetAddress
removeallclassmethods LMStreetAddress
! ------------------- Class methods for LMStreetAddress
category: ''Instance creation''
classmethod: LMStreetAddress
createSampleId: idNum
	| n |
	n := super createSampleId: idNum.
	n streetNumber: (NonRandom 
		randomIntegerBetween: 0 and: 9999).  
	^n
%
! ------------------- Instance methods for LMStreetAddress
category: ''Accessing''
method: LMStreetAddress
streetName
	^streetName
%
category: ''Accessing''
method: LMStreetAddress
streetNumber
	^streetNumber
%
category: ''Operations''
method: LMStreetAddress
printOn: aStream
	aStream nextPutAll: self streetNumber asString.
	aStream nextPutAll: '' ''.
	aStream nextPutAll: self streetName asString.
	
	self apartmentNumber notNil ifTrue:
		[aStream nextPutAll: '' #''.
		aStream nextPutAll: self apartmentNumber asString.
		]
	
%
category: ''Size''
method: LMStreetAddress
totalSize
	| runningSize |
	runningSize := self _primitiveSize.
	runningSize := runningSize + (idString size).
	runningSize := runningSize + (notes size).
	runningSize := runningSize + (startDate size).
	runningSize := runningSize + (longString size).
	runningSize := runningSize + (shortString size).
	runningSize := runningSize + (streetName size).

	^runningSize
%
category: ''Updating''
method: LMStreetAddress
streetName: newValue
	streetName := newValue
%
category: ''Updating''
method: LMStreetAddress
streetNumber: newValue
	streetNumber := newValue
%

! ------------------- Remove existing behavior from NonRandom
removeallmethods NonRandom
removeallclassmethods NonRandom
! ------------------- Class methods for NonRandom
category: ''API''
classmethod: NonRandom
convertToSeed: anIntegerOrString
	"Allow the seed to be a string (such as a version number) or an integer."

	" NonRandom convertToSeed: ''hello'' "

	| value |
	value := anIntegerOrString.
	
	(value isKindOf: String) 
		ifTrue: [anIntegerOrString size < 9 
				ifTrue: [value := value, ''@$#%&*^%%''].
			value := #(1 2 3 4 5 6 7 ) inject: 0 into: [:running :ele | running + ((value at: ele) codePoint * ele)]
			]
		ifFalse: [value := value asInteger].
	
	^value
%
category: ''API''
classmethod: NonRandom
integers: n between: l and: h
	"Answer a collection of n well-distributed unpredicably sequenced integers between l and h. 
	All args must be integers > 0.
	The resulting integers are as widely distributed as possible, no sequences forward or back (except in very
	small ranges).
	Numbers are unique within the range of l and h.  If you request 30 numbers between 1 and 30, the results
	include exactly one occurance of each number 1..30.  If you request 30 numbers between 1 and 10, the
	first 10 results will include exactly one of each, as will the second and third. "

	| start result candidateValues usedValues unusedValues resultValues intervalStart intervalEnd seed value next |

	resultValues := Array new.
	(l = h) ifTrue: [n timesRepeat: [resultValues add: l].  ^resultValues].
	
	candidateValues := Array new: h.
	1 to: h do: [:i | candidateValues at: i put: i.].
	unusedValues := candidateValues copy.

	usedValues := SortedCollection new.
	resultValues := Array new.
	
	"seed value.  Never use 1 just on principle"
	seed := self randomMax: h excluding: 1.
	value := seed.
	resultValues add: value. usedValues add: value. unusedValues remove: value.
	"Grover log: ''int: '', value asString, ''  unused are '', unusedValues printString, '' used values are '', usedValues printString."

	n - 1 timesRepeat: [

	" h is smaller than n, go back and start again with the numbers.  
	Also get a new seed"
	unusedValues isEmpty ifTrue: [
		| prevValue |
		unusedValues := candidateValues copy.
		seed := self randomMax: h excluding: seed. 
		value := seed.
		].

	intervalStart := value + 1.
	[unusedValues includes: intervalStart] whileFalse: [
		intervalStart := intervalStart + 1.
		intervalStart > h ifTrue: [intervalStart := 1]].

	intervalEnd := value - 1.
	[unusedValues includes: intervalEnd] whileFalse: [
		intervalEnd := intervalEnd - 1.
		intervalEnd < 1 ifTrue: [intervalEnd := h]].

	value := self numberIn: unusedValues between: (unusedValues indexOf: intervalStart) and: (unusedValues indexOf: intervalEnd).
	"Grover log: ''int: '', value asString, ''  unused are '', unusedValues printString, '' used values are '', usedValues printString."

	resultValues add: value. usedValues add: value. unusedValues remove: value.
	].


^resultValues



%
category: ''API''
classmethod: NonRandom
numberIn: arrayOfInt between: lowerIndex and: upperIndex

	"select a number from the options in arrayOfInt, ranging from lowerIndex to upperIndex, treating
	arrayOfInt as a circular list so it is legal for upperIndex to be smaller than lowerIndex.
	be randomish, but if the range is large enough, don''t pick a very close index.
	Return the contents at the selected location, not the index of the location."

	| exclusion options lowerLimit upperLimit value num middle |
	lowerIndex = upperIndex ifTrue: [^arrayOfInt at: lowerIndex].

	upperIndex > lowerIndex 
		ifTrue: [options := arrayOfInt copyFrom: lowerIndex to: upperIndex]
		ifFalse: [options := (arrayOfInt copyFrom: lowerIndex to: arrayOfInt size), (arrayOfInt copyFrom: 1 to: upperIndex)].

	"try to avoid both close to the upper, lower, and middle of the range"
	options size < 3
		ifTrue: [lowerLimit := 1. upperLimit := options size]
		ifFalse: [lowerLimit := 2. upperLimit := options size - 1].
	middle := options size // 2.
	num := self randomBetween: lowerLimit and: upperLimit excluding: middle.
	value := options at: num.
	"Grover log: ''lowerLimit is '', lowerLimit asString, '' upperLimit  is '', upperLimit asString, '' num is '', num asString."
	^value

%
category: ''API''
classmethod: NonRandom
randomBetween: l and: h
	"Return a random-ish number between the two values, inclusive.
	Note that the upper limit on what this will return is 4294967296 "

	| range rand val |
	range := (h - l) + 1.
	rand := self _getAnInt  \\ range.
	val := l + rand.
	^val

%
category: ''API''
classmethod: NonRandom
randomBetween: l and: h excluding: unwanted
	"Return a random-ish number between the two values, inclusive."

	| range rand val |
	range := (h - l) + 1.

	"awkward conditions"
	range < 2 ifTrue: [
		unwanted = l ifTrue: [self error: ''bad arg''].
		unwanted = h ifTrue: [^l].
		unwanted = l ifTrue: [^h].
		].

	[rand := self _getAnInt  \\ range.
	val := l + rand.
	val = unwanted
		] whileTrue.

	^val

%
category: ''API''
classmethod: NonRandom
randomFromSeed: anIntegerOrString between: l and: h
	"This is a one-off, and does not affect the class variable the way seed: does. 
	Get a random number based on the seed, which may be a string (such as a version number) or an integer."

	| tempRand range rand val |
	tempRand := Lag1MwcRandom seed: (self convertToSeed: anIntegerOrString).
	^tempRand integerBetween: 1 and: h.


%
category: ''API''
classmethod: NonRandom
randomIn: aCollection
	"Pick something within aCollection.  If aCollection is empty, return nil."
	aCollection isEmpty ifTrue: [^nil].
	^aCollection asArray at: (self randomBetween: 1 and: aCollection size)

%
category: ''API''
classmethod: NonRandom
randomlyReorder: aCollection
	"randomly order a collection.  More randomness occurs when input is sorted"

	| ints result |
	aCollection size <= 2 ifTrue: [^aCollection].
	ints := self integers: aCollection size between: 1 and: aCollection size.
	result := Array new.
	ints do: [:i | result add: (aCollection at: i)].
	^result

%
category: ''API''
classmethod: NonRandom
randomMax: h excluding: n

	"psueodo-random number between 1 and h inclusive, but not using n.
	n and h should be larger than 0. 
	error if an impossible task"

	| rand |
	(h = 1 and: [n = 1]) ifTrue: [self error: ''bad arg''].

	(h = 2) ifTrue: [
		n = 1 ifTrue: [^2].
		n = 2 ifTrue: [^1]].

	rand := (self _getAnInt \\ h) + 1.
	[rand = n] whileTrue: [rand := (self _getAnInt \\ h) + 1].
	^rand
%
category: ''API''
classmethod: NonRandom
seed: anIntegerOrString
	"Allow the seed to be a string (such as a version number) as well as an integer."
	"Use Lag1MwcRandom rather than Random, since initialization time for Random was significant"

	" NonRandom seed: ''hello'' "

	MyRandom := Lag1MwcRandom seed: (self convertToSeed: anIntegerOrString).
%
category: ''API-Random types''
classmethod: NonRandom
randomDateBetween: startDate and: endDate 

	"NonRandom randomDateBetween: (Date today subtractDays: 10) and: Date today. "
	| start end |
	start := startDate asDays.
	end := endDate asDays.
	^startDate addDays: (self randomBetween: 0 and: (end - start)). 
%
category: ''API-Random types''
classmethod: NonRandom
randomFloatBetween: l and: h
	"Return a random-ish number between the two values, inclusive."

	^(self _getAFloat * (h - l)) + l
%
category: ''API-Random types''
classmethod: NonRandom
randomIntegerBetween: l and: h
	^self randomBetween: l and: h

%
category: ''Private''
classmethod: NonRandom
_getAFloat
	| val |
	MyRandom isNil ifTrue: [self seed: 17].
	val := MyRandom float.
	^val
%
category: ''Private''
classmethod: NonRandom
_getAnInt
	| val |
	MyRandom isNil ifTrue: [self seed: 17].
	val := MyRandom integer.
	^val
%
category: ''String Generation''
classmethod: NonRandom
constanentPool

	^{ $b . $c . $d  . $f . $g . $h . $j  . $k . $l . $m . $n  . $p . $r . $s . $t  . $v }
%
category: ''String Generation''
classmethod: NonRandom
generatePoolOfString3 

| pool letters |

pool := UserGlobals at: #IPstring3pool ifAbsent: [nil].
pool isNil ifFalse: [^pool].

letters := self constanentPool, self vowelPool.
pool := Array new.
letters do: [:ch1 |
	letters do: [:ch2 |
		letters do: [:ch3 |
			pool add: (String with: ch1 asUppercase with: ch2 with: ch3)]]].
pool := pool asSortedCollection asArray.
UserGlobals at: #IPstring3pool put: pool.
^pool

%
category: ''String Generation''
classmethod: NonRandom
generateString: limit
	"generate a lower case, first letter capitalized, alphabetic random 
      string with <limit> characters"

	"
	limit 2 : (16 * 4 ) + (4 * 16) = 128 possible
	limit 3:  128 * 20  = 2560  possible
	limit 4:  2560 * 20 =  51200  possible
	limit 5:  51200 * 20 =  1024000 possible"

	| str ws char char2 namestr int ch |
	namestr := String new.
	namestr add: (self randomLCLetter) asUppercase.
	[namestr size < limit]
		whileTrue: [namestr add: self randomLCLetter].

	^namestr
%
category: ''String Generation''
classmethod: NonRandom
randomLCConstanent

	^self constanentPool
		at: (self randomBetween: 1 and: self constanentPool size)
%
category: ''String Generation''
classmethod: NonRandom
randomLCLetter

	| pool |
	pool := self constanentPool, self vowelPool.
	^pool at: (self randomBetween: 1 and: pool size)
%
category: ''String Generation''
classmethod: NonRandom
randomLCVowel 

	^self vowelPool 
		at: (self randomBetween: 1 and: self vowelPool size)
%
category: ''String Generation''
classmethod: NonRandom
randomString3
	^self randomIn: self generatePoolOfString3.
%
category: ''String Generation''
classmethod: NonRandom
stringAtRatio: aFloat
	"NonRandom stringAtRatio: 0.25  "
| possibilities offset |
possibilities := self generatePoolOfString3.
offset := (aFloat * possibilities size) asInteger.
offset < 1 ifTrue: [offset := 1].
offset > possibilities size ifTrue: [offset := possibilities size].

^possibilities at: offset
%
category: ''String Generation''
classmethod: NonRandom
vowelPool

	^{ $a . $e . $i  . $o  }
%
category: ''Testing''
classmethod: NonRandom
differencingIn: anArray
	| str adj num prev diff1adj diff2adj diff1prev diff2prev rating |

	diff1adj := 0. diff2adj := 0.  diff1prev := 0.  diff2prev := 0. 
	adj := anArray at: 1.
	num := anArray at: 2.
	(num - adj) abs = 1 ifTrue: [diff1adj := diff1adj + 1].
	(num - adj) abs = 2 ifTrue: [diff2adj := diff2adj + 1].
	
	3 to: anArray size do: [:i |
		num := anArray at: i.
		adj := anArray at: i - 1.
		prev := anArray at: i - 2.
		(num - adj) abs = 1 ifTrue: [diff1adj := diff1adj + 1].
		(num - adj) abs = 2 ifTrue: [diff2adj := diff2adj + 1].
		(num - prev) abs = 1 ifTrue: [diff1prev := diff1prev + 1].
		(num - prev) abs = 2 ifTrue: [diff2prev := diff2prev + 1].
		].
	str := String new.
	rating := (diff1adj * 5) + (diff2adj * 3) + (diff1prev * 2) + (diff2prev).
	str add: rating asString.
	^str
%
category: ''Testing''
classmethod: NonRandom
distributionIn: anArray
	| str dict |
	dict := Dictionary new.
	anArray do: [:ea |
		(dict includesKey: ea)
			ifTrue: [dict at: ea put: (dict at: ea)  + 1]
 			ifFalse: [dict at: ea put: 1]
		].
	str := String new.
	dict keys asSortedCollection do: [:key |
		str add: key asString, '' -> ''.
		str add: (dict at: key) asString; lf.
		].
	str add: ''stddev: '', (self stdevFor: anArray) asString.
	^str
%
category: ''Testing''
classmethod: NonRandom
stdevFor: anArray
	" NonRandom stdevFor: { 6 . 2 . 3 . 1 } "
	" NonRandom stdevFor: { 1 . 4 . 7 . 2 . 6 }  "
	| sum mean |
	sum := 0.
	anArray do: [:i | sum := sum + i].
	mean := sum / anArray size.
	
	sum := 0.
	anArray do: [:i |sum := sum + (i - mean) squared].
	
	^(sum / anArray size) sqrt

%
category: ''Testing''
classmethod: NonRandom
test_getAntInt
	" NonRandom test_getAntInt"
	| str res n |
	str := String new.
	5 to: 10 do: [:n |
		NonRandom seed: ''3.2.1''.	res := Array new.
		10000 timesRepeat: [res add: (MyRandom integerBetween: 1 and: n)].
		str add: ''MyRandom limit '', n asString, '' stdev: '', (self stdevFor: res) asString; lf.
		NonRandom seed: ''3.2.1''.	res := Array new.
		10000 timesRepeat: [res add: (self _getAnInt  \\ n)].
		str add: ''_getAnInt limit '', n asString, '' stdev: '', (self stdevFor: res) asString; lf.
	].

	^str
%
category: ''Testing''
classmethod: NonRandom
test_integers_between_and

	| str res |
	str := String new.
	NonRandom seed: 17.
	
	"res := NonRandom integers: 500 between: 1 and: 500.
	res size = 500 ifFalse: [self error: ''wrong result''].
	1 to: 500 do: [:i | (res includes: i) ifFalse: [self error: ''missing value'']]."

	res := NonRandom integers: 10 between: 1 and: 10.
	1 to: res size do: [:i |
		str add: (res at: i) asString; space.
		i \\ 10 = 0 ifTrue: [str lf].
		].
	^str.	
	
%
category: ''Testing''
classmethod: NonRandom
test_integers_between_and_2
	" NonRandom test_integers_between_and_2 "
	| str res n |
	str := String new.

	NonRandom seed: ''3.3''.
	n := 5.
	res := NonRandom integers: n * 2 between: 1 and: n.
	1 to: res size do: [:i | str add: (res at: i) asString; space. i \\ n = 0 ifTrue: [str add: ''- '']].
	str add: '' differencing '', (self differencingIn: res); lf.
	

	NonRandom seed: ''3.3''.
	n := 11.
	res := NonRandom integers: n * 2 between: 1 and: n.
	1 to: res size do: [:i | str add: (res at: i) asString; space. i \\ n = 0 ifTrue: [str add: ''- '']].
	str add: '' differencing '', (self differencingIn: res); lf.
	
	NonRandom seed: ''3.3.1''.
	n := 15.
	res := NonRandom integers: n * 2 between: 1 and: n.
	1 to: res size do: [:i | str add: (res at: i) asString; space. i \\ n = 0 ifTrue: [str add: ''- '']].
	str add: '' differencing '', (self differencingIn: res); lf.

	NonRandom seed: ''3.1.0.5''.
	n := 25.
	res := NonRandom integers: n * 2 between: 1 and: n.
	1 to: res size do: [:i | str add: (res at: i) asString; space. i \\ n = 0 ifTrue: [str add: ''- '']].
	str add: '' differencing '', (self differencingIn: res); lf.



	^str.	
	
%
category: ''Testing''
classmethod: NonRandom
test_numberIn_between_and

	 " NonRandom test_numberIn_between_and "

	| val |
	val := NonRandom numberIn: { 1 . 2 . 3 . 4 . 5 . 6 . 7 . 8 . 9 . 10 } between: 1 and:  2 .
	(val = 1 or: [val = 2]) ifFalse: [self error: ''wrong''].

	val := NonRandom numberIn: { 1 . 2 . 3 . 4 . 5 . 6 . 7 . 8 . 9 . 10 } between: 2 and:  1. 
	(val > 4 and: [val < 9])  ifFalse: [self error: ''wrong''].

	val := NonRandom numberIn: { 1 . 2 . 3 . 4 . 5 . 6 . 7 . 8 . 9 . 10 } between: 3 and:  7 .
	(val > 3 and: [val < 7])  ifFalse: [self error: ''wrong''].

	val := NonRandom numberIn: { 1 . 2 . 3 . 4 . 5 . 6 . 7 . 8 . 9 . 10 } between: 7 and:  3.  
	(val > 8 or: [val = 1])  ifFalse: [self error: ''wrong''].

	val :=NonRandom numberIn: { 1 . 2 . 3 . 4 . 5 . 6 . 7 . 8 . 9 . 10 } between: 5 and:  5.
	val = 5 ifFalse: [self error: ''wrong''].

	^''success''

%
category: ''Testing''
classmethod: NonRandom
test_random
	" NonRandom test_random"
	| r str res n |
	str := String new.
	5 to: 40 do: [:n |
		r := Lag1MwcRandom seed: 1234. res := Array new.
		10000 timesRepeat: [res add: (r integer  \\ n)].
		str add: ''integer limit '', n asString, '' stdev: '', ((self stdevFor: res) asString copyFrom: 1 to: 5); lf.
	].

	^str
%
category: ''Testing''
classmethod: NonRandom
test_randomBetween_and
	 " NonRandom test_randomBetween_and "

	| val str |
	str := String new.
	20 timesRepeat: [
		val := NonRandom randomBetween: 3 and: 8. 
		str add: val asString, '' - ''.].
	^str

%
category: ''Testing''
classmethod: NonRandom
test_randomBetween_and_2
	 " NonRandom test_randomBetween_and_2 "

	| val str |
	str := String new.
	NonRandom seed: ''3.3.1''.
	20 timesRepeat: [
		val := NonRandom randomBetween: 1 and: 21. 
		str add: val asString, '' - ''.].
	^str

%
category: ''Testing''
classmethod: NonRandom
test_randomBetween_and_excluding_
	 " NonRandom test_randomBetween_and_excluding_ "

	| val str |
	str := String new.
	NonRandom seed: ''3.3.1''.
	20 timesRepeat: [
		val := NonRandom randomBetween: 1 and: 21 excluding: 7. 
		str add: val asString, '' - ''.].
	str lf.
	NonRandom seed: ''3.1.0.1''.
	20 timesRepeat: [
		val := NonRandom randomBetween: 1 and: 5 excluding: 5. 
		str add: val asString, '' - ''.].
	str lf.
	NonRandom seed: ''3.2.15''.
	20 timesRepeat: [
		val := NonRandom randomBetween: 1 and: 6 excluding: 3. 
		str add: val asString, '' - ''.].
	^str

%
category: ''Testing''
classmethod: NonRandom
test_randomMax_excluding
	 " NonRandom test_randomMax_excluding "

	| val str |
	str := String new.
	20 timesRepeat: [
		val := NonRandom randomMax: 9 excluding: 1. 
		str add: val asString, '' - ''.].
	^str

%
! ------------------- Instance methods for NonRandom

! ------------------- Remove existing behavior from UsSpaceUser
removeallmethods UsSpaceUser
removeallclassmethods UsSpaceUser
! ------------------- Class methods for UsSpaceUser
category: ''Filling Collections''
classmethod: UsSpaceUser
fillWithCustomers: numCustomers
	"This assumes the collections were already created.
	Fill each collection with the same percent of customers.
	Do the fill in four chunks to distribute oops.
	This is not intended to run in parallel with any other work, so takes credit for the entire count diff"

	"IPCustomerCollectionHolder setupCollections: 300000. 
	UsSpaceUser fillWithCustomers: 100000. "

	| ct origSize goalSize setSize added numCollections |
	origSize := IPCustomerCollectionHolder current totalCustomers.
	goalSize := origSize + numCustomers.
	numCollections :=  IPCustomerCollectionHolder current theCollections size.
	setSize := ( (numCustomers / self poolSize)  / numCollections ) asInteger - 1. 
	added := 0.

	self createAndLoginSessions.

	1 to: self poolSize do: [:i |
		self 
			execute:  ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers: '', setSize asString, ''].'' 
			inExternalSessionBasedOn: i.
		].
 	ct := 0.
	[ct < 10000] whileTrue: [
		| collIndex |
		IPCustomerCollectionHolder current totalCustomers >= goalSize ifTrue: [
			self logoutSessions.
			^IPCustomerCollectionHolder current totalCustomers - origSize
			].
		collIndex := ((numCollections \\ (ct + 1)) min: numCollections) max: 1.
		(IPCustomerCollectionHolder current theCollections at: collIndex) addOneCustomer.
		ct := ct + 1
		].

	self logoutAndDeleteSessions.
	^IPCustomerCollectionHolder current totalCustomers - origSize

%
category: ''Infrastructure''
classmethod: UsSpaceUser
createAndLoginSessions

	| s1 result  |
	self logoutAndDeleteSessions.
	self poolSize timesRepeat: [
		s1 := GsTsExternalSession newDefault.
		s1 login.
		self sessionPool add: s1.
		result := s1 executeString: ''System session''.
		GsFile gciLogClient: ''Logging in session '', result asString.
		].
%
category: ''Infrastructure''
classmethod: UsSpaceUser
execute: aString inExternalSessionBasedOn: num
	"num may be out of range, compute the actual session index "

	| s1 result index |
	System commitTransaction.
	index :=  self selectSessionBasedOn: num.
	s1 := self sessionPool at: index.
	result := s1 executeString: ''System session''.
	GsFile gciLogClient: result asString, '': '', (aString copyFrom: 1 to: (100 min: aString size)).
	result := s1 executeString: aString.
	^result


%
category: ''Infrastructure''
classmethod: UsSpaceUser
logoutAndDeleteSessions

	self sessionPool do: [:ea | ea logout].
	self sessionPool size: 0.



%
category: ''Infrastructure''
classmethod: UsSpaceUser
logoutSessions

	self sessionPool do: [:ea | ea logout].


%
category: ''Infrastructure''
classmethod: UsSpaceUser
longString
^''# STN_STATMONITOR_ARGS
#
# A list of lists of arguments used to start one or more statmonitor
# processes. If the list is not an empty string, one statmonitor process
# for each element in the list will be automatically started by the stone
# at startup time.
#
# The list of possible statmonitor arguments may be obtained by invoking
# statmonitor with only the "-h" argument. The name of the stone argument to
# statmonitor is passed automatically and must not be included here. The
# -X statmonitor argument is not allowed and statmonitor will not be
# started if -X is detected.
#
# A maximum of 64 argument lists may be specified. Each argument list
# must contain between 2 and 1023 characters. List elements must be
# contained within double quotes and separated by commas.
#
# Example: start two statmonitor processes, the first with a 10 second
#          sample interval and the second with a 60 second sample
#          interval. Both processes place a date and timestamp in the output
#          file name and place the output file in the directory
#          $GEMSTONE/data:
#
# STN_STATMONITOR_ARGS =
#
# Default: "" (Statmonitor will not be started)
#STN_STATMONITOR_ARGS = "";

#=========================================================================
# STN_STONE_CACHE_STARTUP_TIMEOUT
#
#  Time in seconds allowed for the startup of the shared cache on the 
#  stone machine. This is time from when the stone forks the page cache
#  monitor process until it is able to complete its connection to that 
#  process.
#
#  The configured value may be overridden for large caches,
#  If cache is 32GB or larger, the actual minimum timeout will be 120
#  seconds, scaling up to 5 minutes for a 300GB cache.
#  For caches less than 32GB, small configured values may also
#  be overriden.
#
#  Default: 60  Min: 10 Max: 1800
#STN_STONE_CACHE_STARTUP_TIMEOUT = 60;

#=========================================================================
# STN_SYMBOL_GC_ENABLED
#
#  Determines if symbol garbage collection is allowed to run on the system
#  Setting this value to true enables symbol garbage collection.
# 
#  Runtime equivalent: #StnSymbolGcEnabled
#    (requires GarbageCollection privilege)
# Default: FALSE
#STN_SYMBOL_GC_ENABLED = FALSE;

#=========================================================================
# STN_SYMBOL_GEM_TEMPOBJ_CACHE_SIZE
#
#  Temporary object memory size of the Symbol Gem .
#
#  Runtime equivalent: #StnSymbolGemTocSize   .
#  StnSymbolGemTocSize is initialized from STN_SYMBOL_GEM_TEMPOBJ_CACHE_SIZE
#  at stone startup. If the Symbol Gem dies other than from an explicit
#  execution of   System stopSymbolGem,  then the first auto restart since
#  the latter of stone startup or runtime change to StnSymbolGemTocSize
#  will double the value of StnSymbolGemTocSize .
#
#  If repository conversion is detected at stone startup (startstone -C)
#  the default is 200MB .
#
# Default units: KB. Suffixes KB, MB, GB may be used to specify units.
# Default: 20MB Min: 10000KB Max: 10GB .
#STN_SYMBOL_GEM_TEMPOBJ_CACHE_SIZE = 20MB ;

#=========================================================================
# STN_TRAN_FULL_LOGGING
#    If TRUE, all transactions are logged, and log files are not deleted
#  by the system. If an element in STN_TRAN_LOG_DIRECTORIES is a raw partition,
#  the contents of that partition must be copied to a file system with
#  copydbf and the partition erased with removedbf before that element of
#  STN_TRAN_LOG_DIRECTORIES is needed again. Likewise, log files must
#  be moved out of directories within STN_TRAN_LOG_DIRECTORIES to
#  prevent file systems from filling up.
#
#    If FALSE, only transactions smaller than STN_TRAN_LOG_LIMIT are logged; 
#  larger transactions become checkpoints, and log files are deleted by
#  the system when the circular list of log directories wraps around.
#
#  Once stone has been started on a repository with 
#      STN_TRAN_FULL_LOGGING = TRUE, then the TRUE state
#  will persist in the repository and subsequent changes to this parameter
#  in the config file will be ignored. To change the repository back to
#  partial logging you must do a full backup and then restore the backup into
#  a copy of $GEMSTONE/bin/extent0.dbf .
#
# There is no default value.
# An explicit value of TRUE is provided at the end of this file.'' 
%
category: ''Infrastructure''
classmethod: UsSpaceUser
poolSize
	^5
%
category: ''Infrastructure''
classmethod: UsSpaceUser
selectSessionBasedOn: num
	"num may be out of range, compute the actual session index "

	| index |
	index :=  (num + self sessionPool size - 1 \\ self sessionPool size) + 1.
	GsFile gciLogClient: ''num is '', num asString, '' sessionPool size is '', self sessionPool size asString, '' index is '', index asString.
	^index
%
category: ''Infrastructure''
classmethod: UsSpaceUser
sessionPool
	| sp |
	sp := SessionTemps current at: #UsSessionPool ifAbsent: [nil].
	sp isNil ifTrue: [SessionTemps current at: #UsSessionPool put: Array new].
	^SessionTemps current at: #UsSessionPool
%
category: ''Making Changes''
classmethod: UsSpaceUser
initialize
	IPCustomerCollectionHolder initialize
%
category: ''Making Changes''
classmethod: UsSpaceUser
makeUpdatesFor: secsToWork
	"UsSpaceUser makeUpdatesFor: 5"

	| thisSet startTime changesPerRun totalChanges start end usedSeconds maxId |
	startTime := Time now asSeconds.
	changesPerRun := 1000.
	totalChanges := 0.

	maxId := IPCustomerCollectionHolder current theCollections first size.
	2 to: IPCustomerCollectionHolder current theCollections size do: [:i | | sz |
		(sz := IPCustomerCollectionHolder current theCollections size) > maxId ifTrue: [maxId := sz]].
	maxId := maxId - 100.

	[start := NonRandom randomBetween: 1 and: maxId.
	end := start + changesPerRun.
	usedSeconds := Time now asSeconds - startTime.
	GsFile gciLogServer: ''worked for '', usedSeconds asString, '' seconds, total '', totalChanges asString, '' changes made''.
	usedSeconds > secsToWork ] whileFalse: 
		[
		GsFile gciLogServer: ''Starting batch of updates with ids starting at '', start asString.
		IPCustomerCollectionHolder current theCollections do: [:ea | | chgs |
			thisSet := ea theCustomers select: {:ea | (ea.id > start) & (ea.id < end)}.
			chgs := self makeUpdatesToCountElements: changesPerRun in: thisSet.
			ea removeOneCustomer. 
			ea addOneCustomer.
			System commitTransaction ifFalse: [GsFile gciLogServer: ''Commit failed; change size reports may be wrong''. System abortTransaction].
			totalChanges := totalChanges + chgs + 2.	
			].
		].
	System commitTransaction ifFalse: [System abortTransaction].
	^totalChanges asString, '' elements updated in '', secsToWork asString, '' seconds''
%
category: ''Making Changes''
classmethod: UsSpaceUser
makeUpdatesToCountElements: num in: aCollection
 	| ctr |
	ctr := 0.

	aCollection do: 
		[:aCustomer |
		aCustomer longString: (self longString, self longString).
		aCustomer contactInfo address mediumString: self longString copy.
		aCustomer contactInfo address street: (LMStreetAddress createSampleId: aCustomer id).
		ctr := ctr + 1.
		ctr > num ifTrue: [ 
			System commitTransaction ifFalse: [GsFile gciLogServer: ''Commit failed; change size reports may be wrong''. System abortTransaction].
			GsFile gciLogServer: ''completed a batch of updates''.
			^ctr].
		ctr > 5000 ifTrue: [	System commitTransaction ifFalse: [GsFile gciLogServer: ''Commit failed; change size reports may be wrong''. System abortTransaction].].
		].
 
	System commit. 
	^ctr

			
%
category: ''Making Changes''
classmethod: UsSpaceUser
makeUpdatesUntilRepositorySizeMB: sizeMB
	"note that the way pages are used is not even so this will fill to somewhat over the requested value.  It will slow down change rate as it gets closer."
	"UsSpaceUser makeUpdatesUntilRepositorySizeMB: 5"

	| thisSet changesPerRun totalChanges start end usedSpace startTime maxId |
	totalChanges := 0.
	startTime := Time now asSeconds.
	(usedSpace := self usedSpaceMb) >= sizeMB ifTrue: [^totalChanges asString, '' elements updated in '', (Time now asSeconds - startTime) asString, '' seconds, repository space used is '', usedSpace asString ].

	changesPerRun := 500.
	maxId := IPCustomerCollectionHolder current theCollections first size.
	2 to: IPCustomerCollectionHolder current theCollections size do: [:i | | sz |
		(sz := IPCustomerCollectionHolder current theCollections size) > maxId ifTrue: [maxId := sz]].
	maxId := maxId - 100.

	[start := NonRandom randomBetween: 1 and: maxId.
	end := start + changesPerRun.
	usedSpace := self usedSpaceMb.
	(totalChanges > 0 and: [usedSpace + 200 > sizeMB]) ifTrue: [System _sleepMs: 100].
	(totalChanges > 0 and: [usedSpace + 100 > sizeMB]) ifTrue: [System _sleepMs: 500].
	GsFile gciLogServer: ''worked for '', (Time now asSeconds - startTime) asString, '' seconds, total '', totalChanges asString, '' changes made, repository space used is '', usedSpace asString.
	usedSpace <= sizeMB] whileTrue: 
		[
		GsFile gciLogServer: ''Starting batch of updates with ids starting at '', start asString.
		IPCustomerCollectionHolder current theCollections do: [:ea | | chgs |
			thisSet := ea theCustomers select: {:ea | (ea.id > start) & (ea.id < end)}.
			chgs := self makeUpdatesToCountElements: changesPerRun in: thisSet.
			ea removeOneCustomer. 
			ea addOneCustomer.
			System commitTransaction ifFalse: [GsFile gciLogServer: ''Commit failed; change size reports may be wrong''. System abortTransaction].
			totalChanges := totalChanges + chgs + 2.	
			].
		].
	System commitTransaction ifFalse: [System abortTransaction].
	^totalChanges asString, '' elements updated in '', (Time now asSeconds - startTime) asString, '' seconds, repository space used is '', usedSpace asString 
%
category: ''Making Changes''
classmethod: UsSpaceUser
makeUpdatesWithSleepsFor: secsToWork
	"UsSpaceUser makeUpdatesWithSleepsFor: 5"

	| thisSet startTime changesPerRun totalChanges start end usedSeconds maxId |
	startTime := Time now asSeconds.
	changesPerRun := 5.
	totalChanges := 0.

	maxId := IPCustomerCollectionHolder current theCollections first size.
	2 to: IPCustomerCollectionHolder current theCollections size do: [:i | | sz |
		(sz := IPCustomerCollectionHolder current theCollections size) > maxId ifTrue: [maxId := sz]].
	maxId := maxId - 100.

	[start := NonRandom randomBetween: 1 and: maxId.
	end := start + changesPerRun.
	usedSeconds := Time now asSeconds - startTime.
	GsFile gciLogServer: ''worked for '', usedSeconds asString, '' seconds, total '', totalChanges asString, '' changes made''.
	usedSeconds > secsToWork ] whileFalse: 
		[
		GsFile gciLogServer: ''Starting batch of updates with ids starting at '', start asString.
		IPCustomerCollectionHolder current theCollections do: [:ea | | chgs |
			thisSet := ea theCustomers select: {:ea | (ea.id > start) & (ea.id < end)}.
			chgs := self makeUpdatesToCountElements: changesPerRun in: thisSet.
			System _sleepMs: 200.
			System commitTransaction ifFalse: [GsFile gciLogServer: ''Commit failed; change size reports may be wrong''. System abortTransaction].
			ea removeOneCustomer. 
			System _sleepMs: 200.
			System commitTransaction ifFalse: [GsFile gciLogServer: ''Commit failed; change size reports may be wrong''. System abortTransaction].
			ea addOneCustomer.
			System _sleepMs: 200.
			System commitTransaction ifFalse: [GsFile gciLogServer: ''Commit failed; change size reports may be wrong''. System abortTransaction].
			totalChanges := totalChanges + chgs + 2.	
			].
		].
	System commitTransaction ifFalse: [System abortTransaction].
	^totalChanges asString, '' elements updated in '', secsToWork asString, '' seconds''
%
category: ''old''
classmethod: UsSpaceUser
doInExternalSession: aString

	| s1 result  |
	System commitTransaction.
	GsFile gciLogClient: (aString copyFrom: 1 to: (100 min: aString size)).
	s1 := GsTsExternalSession newDefault.
	s1 login.
	result := s1 executeString: aString.
	s1 logout.
	^result
%
category: ''old''
classmethod: UsSpaceUser
fill: aCollection withCustomers: num
	"we allow filling partway so we can distribute oops 
	of newly created objects between collections"

	| toAdd |
	GsFile gciLogServer: ''Filling collection with '', num asString, '' customers, currently '',  aCollection theCustomers size asString, '' filling to '', aCollection intendedSize asString.

	aCollection theCustomers size >= aCollection intendedSize
		ifTrue: [^self].
	
	toAdd := (aCollection intendedSize - aCollection theCustomers size) min: num.
	1 to: toAdd do: [:i |
		aCollection theCustomers add: (LMCustomer createSampleId: self counter).
		(i \\ 10000) = 0 ifTrue: [
			| res |	
			res := System commitTransaction.
			res 
				ifTrue: [GsEventLog logTrace: ''  Added 10000 customers; commit'']
				ifFalse: [System abort. GsEventLog logTrace: ''commit failed; aborting''].
			].
		].
%
category: ''old''
classmethod: UsSpaceUser
fill: aCollection withCustomersToAddMB: targetAddedSpace
	"UsSpaceUser fill: IPCustomerCollectionHolder current theCollections first withCustomersToAddMB: 2"

	|  aCustomer currentSize startingUsed perCount res added numToAdd ctr |
	startingUsed := self usedSpaceMb.
	aCustomer := LMCustomer createSampleId: aCollection counter.
	aCollection theCustomers add: aCustomer.
	numToAdd := ((targetAddedSpace * 1000000) / aCustomer totalSize) asInteger.
	ctr := 0.
	GsFile gciLogServer: ''Starting with '', startingUsed asString, ''MB, adding '', numToAdd asString, '' customers to fill to by '', targetAddedSpace asString, '' MB''.
	added := 0.
	numToAdd timesRepeat: [
		aCollection theCustomers add: (LMCustomer createSampleId: aCollection counter).
		ctr := ctr + 1.
		(ctr \\ 150) = 0 ifTrue: 
				[(System commitTransaction) ifTrue: [added := added + 150] ifFalse: [System abort].
				GsFile gciLogServer: ''  Added 50 customers, now '', added asString, '' customers added, repos uses '',  self usedSpaceMb asString, '' MB''].
		].
	^self usedSpaceMb asString, ''MB added '', added asString, '' customers''



%
category: ''old''
classmethod: UsSpaceUser
fillOLD: aCollection withCustomersToAddMB: targetAddedSpace
	"UsSpaceUser fill: IPCustomerCollectionHolder current theCollections first withCustomersToAddMB: 2"

	|  currentSize startingUsed perCount res added |
	startingUsed := self usedSpaceMb.
	GsFile gciLogServer: ''Starting with '', startingUsed asString, ''MB, aiming to fill to by '', targetAddedSpace asString, '' MB''.
	added := 0.
	1 to: 1000000 by: 1 do: [:i |
		aCollection theCustomers add: (LMCustomer createSampleId: aCollection counter).
		aCollection theCustomers add: (LMCustomer createSampleId: aCollection counter + 1).
		(System commitTransaction)
			ifTrue: [added := added + 1]
			ifFalse: [System abort].
		(currentSize := self usedSpaceMb) >= (startingUsed + targetAddedSpace)
		 	ifTrue: [
				GsFile gciLogServer: ''Added '', added asString, '' elements to reach '', currentSize asString, ''MB''.  
				^added].
		(i \\ 50) = 0 ifTrue: [GsFile gciLogServer: ''  Added 20 customers, now '', currentSize asString, ''MB''].
		
		(currentSize + 10) >= (startingUsed + targetAddedSpace) ifTrue: [System _sleepMs: 100].
		].
	^''1000000 was not enough to fill with '', targetAddedSpace asString, '' MB of disk use''.


%
category: ''old''
classmethod: UsSpaceUser
fillWithData
	"UsSpaceUser initialize. UsSpaceUser fillWithData. "
	| used |
	used := self usedSpaceMb.
	IPCustomerCollectionHolder current theCollections add: (IPCustomerCollection createForSize:  4000).
	IPCustomerCollectionHolder current theCollections add: (IPCustomerCollection createForSize: 20000).
	IPCustomerCollectionHolder current theCollections add: (IPCustomerCollection createForSize: 14000).

	self doInExternalSession: ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers: 10000].''.
	self doInExternalSession: ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers: 50000].''.
	self doInExternalSession: ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers].''.
	^self usedSpaceMb - used

%
category: ''old''
classmethod: UsSpaceUser
fillWithDataOLD
	"UsSpaceUser initialize. UsSpaceUser fillWithData. "
	| used |
	used := self usedSpaceMb.
	IPCustomerCollectionHolder current theCollections add: (IPCustomerCollection createForSize:  4000).
	IPCustomerCollectionHolder current theCollections add: (IPCustomerCollection createForSize: 20000).
	IPCustomerCollectionHolder current theCollections add: (IPCustomerCollection createForSize: 14000).

	self doInExternalSession: ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers: 10000].''.
	self doInExternalSession: ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers: 50000].''.
	self doInExternalSession: ''IPCustomerCollectionHolder current theCollections do: [:ea | ea fillWithCustomers].''.
	^self usedSpaceMb - used

%
category: ''Repository Stats''
classmethod: UsSpaceUser
freePagesMB
	^(((System stoneCacheStatisticWithName: ''FreePages'') * 16384) / 1024000) asInteger.

%
category: ''Repository Stats''
classmethod: UsSpaceUser
usedSpaceMb
	| size free |
	size := (System stoneCacheStatisticWithName: ''ReposSizeMB'').
	free := (((System stoneCacheStatisticWithName: ''FreePages'') * 16384) / 1024000) asInteger.
	^size - free.
%
! ------------------- Instance methods for UsSpaceUser
' replaceCrWithLf
]

{ #category : 'constants' }
JadeiteForPharoBrowserWithoutRowanTestCase >> fileInFilePath [

	^ 'fileInTestFile.gs'
]

{ #category : 'support' }
JadeiteForPharoBrowserWithoutRowanTestCase >> jfp_compileClassExpectedClassDefinition [

	^ 'Object rwSubclass: ''TestClass''
	instVarNames: #( abc)
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Core''
	options: #()' replaceCrWithLf
]

{ #category : 'support' }
JadeiteForPharoBrowserWithoutRowanTestCase >> jfpwor_compileClassExpectedClassDefinition [

	^ '(Object subclass: ''TestClass''
  instVarNames: #( abc)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UserGlobals
  options: #()
) category: ''Kernel''' replaceCrWithLf
]

{ #category : 'private' }
JadeiteForPharoBrowserWithoutRowanTestCase >> performTest [

	JadeitePreferences isRowanAvailable ifTrue: [
		^ self skip: 'Rowan is available. Test not run' ].
	^ super performTest
]

{ #category : 'selection' }
JadeiteForPharoBrowserWithoutRowanTestCase >> selectRowanAnsweringService [

	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Core';
			 substringIndex: 3;
			 yourself).
	self
		selectServiceNamed: 'RowanAnsweringService'
		in: self classListPresenter
]

{ #category : 'selection' }
JadeiteForPharoBrowserWithoutRowanTestCase >> selectRowanSample1Class [
	"tests put the sample class in a few locations"

	self
		selectServiceNamed: self rowanSampleDictionaryName
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: RowanClassCategoryService new nilCategoryDisplayName;
			 substringIndex: 1;
			 yourself).
	self classCategoryPresenter selectedItem ifNil: [
		self classCategoryPresenter selectItem:
			(RowanClassCategoryService new
				 name: 'Kernel';
				 substringIndex: 1;
				 yourself) ].
	self classCategoryPresenter selectedItem ifNil: [
		self classCategoryPresenter selectItem:
			(RowanClassCategoryService new
				 name: 'RowanSample1-Core';
				 substringIndex: 2;
				 yourself) ].
	self
		selectServiceNamed: self sampleClassName
		in: self classListPresenter
]

{ #category : 'selection' }
JadeiteForPharoBrowserWithoutRowanTestCase >> selectRowanSample1Test [

	self selectRowanSample1TestIn: self projectsPresenter
]

{ #category : 'selection' }
JadeiteForPharoBrowserWithoutRowanTestCase >> selectRowanSample1TestIn: browser [

	self
		selectServiceNamed: self rowanSampleDictionaryName
		in: browser dictionaryListPresenter.



	browser classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Kernel';
			 substringIndex: 1;
			 yourself).

	browser classCategoryPresenter selectedItem ifNil: [
		browser classCategoryPresenter selectItem:
			(RowanClassCategoryService new
				 name: 'RowanSample1-Test';
				 substringIndex: 2;
				 yourself) ].
	self
		selectServiceNamed: 'RowanSample1Test'
		in: browser classListPresenter
]

{ #category : 'selection' }
JadeiteForPharoBrowserWithoutRowanTestCase >> selectRowanServicesPackage [
	"no package list"
]

{ #category : 'selection' }
JadeiteForPharoBrowserWithoutRowanTestCase >> selectServicesNamed: services in: presenter [
	"no selection done for package list. Not used in JfPwoR"

	self packageListPresenter == presenter ifTrue: [ ^ self ].
	(self projectListPresenter == presenter and: [
		 services first = 'RowanSample1' ]) ifTrue: [
		^ super
			  selectServicesNamed: #( self rowanSampleDictionaryName )
			  in: presenter "think/hope we only select one package at a time in practice" ].
	(self projectListPresenter == presenter and: [
		 services first = 'Rowan' ]) ifTrue: [
		^ super selectServicesNamed: #( 'Published' ) in: presenter ].
	^ super selectServicesNamed: services in: presenter
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> servicesTestsLoaded [

	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self classListPresenter selectedItem ifNil: [ ^ false ].
	^ true
]

{ #category : 'support' }
JadeiteForPharoBrowserWithoutRowanTestCase >> setUp [

	super setUp.
	self setupProjectBrowser
]

{ #category : 'support' }
JadeiteForPharoBrowserWithoutRowanTestCase >> tearDown [

	GciSession current isValidSession ifTrue: [
		JadeitePreferences isRowanAvailable
		"	ifTrue: [ self unloadSampleProject1 ]"
			ifFalse: [
				JadeiteBrowserPresenter
					basicRemoveDictionaryNamed: self rowanSampleDictionaryName
					onCompletion: [  ] ] ].
	super tearDown
]

{ #category : 'constants' }
JadeiteForPharoBrowserWithoutRowanTestCase >> testFileInWorkingDirectory [

	^ 'FileSystem disk workingDirectory'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_abortRemovesCategory [

	| className classCategoryService children browserService |
	true ifTrue: [
			^ self skip:
				  'Test hangs. Need better solutions for abort that does not issue commands in abort events on the client' ].
	className := 'PublishedClass'.
	self selectServiceNamed: 'Published' in: self dictionaryListPresenter.
	self
		saveClass: className
		superclass: 'Object'
		instVars: #(  )
		package: nil
		dictionaryName: 'Published'
		classCategory: ''.
	self
		assert: self classListPresenter selectedItem name
		equals: className.
	self
		assert: self classCategoryPresenter selectedItem name
		equals: RowanClassCategoryService nilClassCategory name.
	classCategoryService := self classCategoryPresenter roots first.
	children := self classCategoryPresenter children value:
		            classCategoryService.
	self assert: children size equals: 2.
	self assert: children first name equals: 'STON-Core'.
	self
		assert: children last name
		equals: RowanClassCategoryService nilClassCategory name.

	browserService := RowanBrowserService new
		                  command: #abortTransactionAndUpdateServices:;
		                  commandArgs: (Array with: Array new).
	RowanServiceUpdater current
		issueCommand: browserService
		session: session
		onCompletion: [
				self projectsPresenter abortedTransaction.
				self assertIsNil: (self classListPresenter list
						 detect: [ :classService | classService name = className ]
						 ifNone: [ ]).
				self
					assert: self classCategoryPresenter selectedItem name
					equals: 'All'.
				children := self classCategoryPresenter children value:
					            classCategoryService.
				self assert: children size equals: 1.
				self assert: children first name equals: 'STON' ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_abstractTestClassesHaveNoRunButton [

	self
		testsJadeiteForPharoIssue: #issue166
		title: 'Running sunit tests from button on class'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/166'.
	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan';
			 substringIndex: 1;
			 yourself).
	self classListPresenter items do: [ :classService |
		| isAbstract stream |
		stream := WriteStream on: String new.
		stream
			nextPut: $[;
			nextPutAll: classService name;
			nextPutAll: ' isAbstract] on: Error do:[:ex | nil]'.
		isAbstract := session executeString: stream contents.

		isAbstract
			ifNil: [
				self assertIsNil:
					(self classListPresenter displayIcon value: classService) ]
			ifNotNil: [
				isAbstract
					ifTrue: [
						self assertIsNil:
							(self classListPresenter displayIcon value: classService) ]
					ifFalse: [
						self assert:
							((self classListPresenter displayIcon value: classService)
								 isKindOf: IconicButtonMorph) ] ] ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_browseClass [
	"project browser opened in setup"

	projectsBrowser ifNotNil: [
		self closeBrowser: projectsBrowser.
		self setupProjectBrowser ].
	self assert: projectsBrowser class equals: JadeiteBrowserWithoutRowan.
	self denyIsNil: (self dictionaryListPresenter list
			 detect: [ :projectService | projectService name = 'RowanKernel' ]
			 ifNone: [  ])
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_changeClassCategoryWhenHierarchyViewOpen [

	| canonicalizationClasses canonicalizationHierarchyClasses |
	self projectsPresenter selectDictionaryNamed: 'Globals'.
	self selectClassCategoryNamed: 'Canonicalization'.
	canonicalizationClasses := (self classListPresenter items
		                            asSortedCollection: [ :x :y |
		                            x name < y name ]) asArray.
	canonicalizationClasses do: [ :classService |
		self assert: classService classCategory equals: 'Canonicalization' ].
	self selectHierarchyTab.
	canonicalizationHierarchyClasses := ((self classHierarchyServices
		                                      select: [ :classService |
			                                      self updateService:
				                                      classService.
			                                      classService classCategory
			                                      = 'Canonicalization' ])
		                                     asSortedCollection: [ :x :y |
		                                     x name < y name ]) asArray.
	self
		assert: canonicalizationClasses
		equals: canonicalizationHierarchyClasses.
	self selectClassCategoryNamed: 'Announcements-Core-GemStone-Test'.
	canonicalizationHierarchyClasses := (self classHierarchyServices
		                                     select: [ :classService |
			                                     self updateService:
				                                     classService.
			                                     classService classCategory
			                                     = 'Canonicalization' ])
		                                    asArray.
	self assert: canonicalizationHierarchyClasses isEmpty
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_classCategorySingleExpansion [
	"class category tree only expanded to level 1 after dictionary selection"

	| itemCount |
	true ifTrue: [ ^ self "referting fix and removing test for now" ].
	self
		testsJadeiteForPharoIssue: #issue374
		title:
		'JfPwoR ... "dictionary view" ... when you click on a dictionary, the Categories are opened fully expanded'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/374'.

	self projectsPresenter selectDictionaryNamed: 'Globals'.
	itemCount := 0.
	self classCategoryPresenter traverseTreeDo: [ :item :path |
			itemCount := itemCount + 1.
			path = #( 1 )
				ifTrue: [
				self assert: (self classCategoryPresenter isExpanded: #( 1 )) ]
				ifFalse: [
				self deny: (self classCategoryPresenter isExpanded: path) ] ].
	self assert: itemCount > 100 "better be big or something weird has happened to the test"
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_classDefUpdatesOnClassCategoryChange [

	JadeitePreferences isRowanAvailable ifFalse: [
		^ self todo: 'not updated for rowan-stubbed servers yet' ].
	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self classCategoryPresenter unselectAll.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self
		assert:
		self projectsPresenter classDefinitionPresenter text trimBlanks
		equals: 'Object rwSubclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Rowan-Services-Tests''
	options: #()' trimBlanks replaceCrWithLf.
	self classCategoryPresenter unselectAll.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Core';
			 substringIndex: 3;
			 yourself).
	self
		assert:
		self projectsPresenter classDefinitionPresenter text trimBlanks
		equals: 'Object rwSubclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Rowan-Services-Core''
	options: #()' trimBlanks replaceCrWithLf.
	self classCategoryPresenter unselectAll.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services';
			 substringIndex: 2;
			 yourself).
	self
		assert:
		self projectsPresenter classDefinitionPresenter text trimBlanks
		equals: 'Object rwSubclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Rowan-Services''
	options: #()' trimBlanks replaceCrWithLf.
	self classCategoryPresenter unselectAll.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan';
			 substringIndex: 1;
			 yourself).
	self
		assert:
		self projectsPresenter classDefinitionPresenter text trimBlanks
		equals: 'Object rwSubclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Rowan''
	options: #()' trimBlanks replaceCrWithLf.
	self classCategoryPresenter unselectAll.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self
		assert:
		self projectsPresenter classDefinitionPresenter text trimBlanks
		equals: 'Object rwSubclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Rowan-Services-Tests''
	options: #()' trimBlanks replaceCrWithLf.
	self projectsPresenter selectClassNamed: 'RowanAnsweringServiceTest'.
	self
		assert:
		self projectsPresenter classDefinitionPresenter text trimBlanks
		equals:
			'RowanServicesTest rwSubclass: ''RowanAnsweringServiceTest''
	instVarNames: #( service)
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Rowan-Services-Tests''
	options: #()' trimBlanks replaceCrWithLf
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_classDefinitionTemplate [

	JadeitePreferences isRowanAvailable ifTrue: [
		^ self skip:
			  'test_classDefinitionTemplate only available in stubbed image' ].
	self
		testsJadeiteForPharoIssue: #issue418
		title:
		'Navigating and category creation in class hiearchy view can''t keep class side/instance side straight'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/314'.
	self
		selectServiceNamed: self rowanSampleDictionaryName
		in: self dictionaryListPresenter.
	self
		assert: (self projectsPresenter classCategoryPresenter selectedItem
				isKindOf: RowanAllClassCategoryService).
	self
		assert: self projectsPresenter classDefinitionPresenter text
		equals: '(Object subclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	inDictionary: RowanSample1Dictionary
	options: #()) category:  ''''
' replaceCrWithLf.

	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
self
		assert: (self projectsPresenter classCategoryPresenter selectedItem
				isKindOf: RowanAllClassCategoryService).
	self
		assert: self projectsPresenter classDefinitionPresenter text
		equals: '(Object subclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	inDictionary: RowanClientServices
	options: #()) category:  ''''
' replaceCrWithLf
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_classListNotEmptyAfterHierarchy [

	| canonicalizationClasses canonicalizationHierarchyClasses |
	self projectsPresenter selectDictionaryNamed: 'Globals'.
	self selectClassCategoryNamed: 'Canonicalization'.
	canonicalizationClasses := (self classListPresenter items
		                            asSortedCollection: [ :x :y |
		                            x name < y name ]) asArray.
	canonicalizationClasses do: [ :classService |
		self assert: classService classCategory equals: 'Canonicalization' ].
	self selectHierarchyTab.
	canonicalizationHierarchyClasses := ((self classHierarchyServices
		                                      select: [ :classService |
			                                      self updateService:
				                                      classService.
			                                      classService classCategory
			                                      = 'Canonicalization' ])
		                                     asSortedCollection: [ :x :y |
		                                     x name < y name ]) asArray.
	self
		assert: canonicalizationClasses
		equals: canonicalizationHierarchyClasses.
	self selectClassCategoryNamed: 'Announcements-Core-GemStone-Test'.
	self selectClassListTab.
	self deny: self classListPresenter items isEmpty.
	self classListPresenter items do: [ :classService |
		self
			assert: classService classCategory
			equals: 'Announcements-Core-GemStone-Test' ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_compileClass [

	self
		testsIssue: #issue390
		withTitle:
		'Rename instance variable with accessor method is... wonky'.
	self selectRowanSample1Class.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #( 'abc' )
		package: 'RowanSample1-Core'.

	self
		assert: self projectsPresenter selectedClass name
		equals: 'TestClass'.
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	self
		assert:
		self projectsPresenter classDefinitionPresenter text trimBlanks
		equals: self compileClassExpectedClassDefinition
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_createClassWithDifferentCategorySelected [

	self projectsPresenter selectDictionaryNamed: 'RowanClientServices'.
	self projectsPresenter classDefinitionPresenter text:
		'(Object subclass: ''NewSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	inDictionary: UserGlobals
	options: #()) category: ''NewCategory'''.
	self projectsPresenter classDefinitionPresenter triggerSubmitAction.
	self
		assert: self projectsPresenter selectedClass name
		equals: 'NewSubclass'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_fileInShowsAddedDictionary [

	| dictionaryNames newDictionaryName |
	self createFileInFileToDisk.
	[
		dictionaryNames := self dictionaryListPresenter list collect: [
			                   :dictionaryService | dictionaryService name ].
		newDictionaryName := 'UseSpace'.
		self deny: (dictionaryNames includes: newDictionaryName).
		projectsBrowser basicFileInServerFile: self testFileInWorkingDirectory. 
		dictionaryNames := self dictionaryListPresenter list collect: [
			                   :dictionaryService | dictionaryService name ].
		self assert: (dictionaryNames includes: newDictionaryName) ]
		ensure: [ "self deleteFileInFileToDisk" ]
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_findClass [

	JadeitePreferences isRowanAvailable ifFalse: [
		^ self skip: 'classes are in different packages' ].
	self projectsPresenter
		updateAfterFindClass: (RowanClassService new name: 'RwGsPlatform')
		methodService: nil
		onCompletion: [  ].
	self
		assert: self classListPresenter selectedItem name
		equals: 'RwGsPlatform'.
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'RowanKernel'.
	self
		assert: self classCategoryPresenter selectedItem name
		equals: 'Rowan-GemStone-Core'.
	self projectsPresenter
		updateAfterFindClass:
		(RowanClassService new name: 'CypressClassDefinition')
		methodService: nil
		onCompletion: [  ].
	self
		assert: self classListPresenter selectedItem name
		equals: 'CypressClassDefinition'.
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'Globals'.
	self
		assert: self classCategoryPresenter selectedItem name
		equals: 'Cypress-Definitions'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_findClassSelectedCategoryVisible [

	| index |
	self projectsPresenter
		updateAfterFindClass: (RowanClassService new name: 'ExampleSetTest')
		methodService: nil
		onCompletion: [ ].
	self
		assert: self classListPresenter selectedItem name
		equals: 'ExampleSetTest'.
	index := self classCategoryPresenter adapter widget selectedIndex.
	"the hierarchy should be long enough that we can kind of tell it scrolled"
	self assert:
		(self classCategoryPresenter adapter widget isIndexVisible: index).
	self deny:
		(self classCategoryPresenter adapter widget isIndexVisible: 1)
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_findClassWithNilClassCategory [
	"When selecting a class, don't reset the class category
	selection to the full class category path."

	self jadeiteTestResourceClass current
		createRowanSample1ProjectWithEmpyClassCategory.
	self projectsPresenter findClassNamed: 'RowanSample1'.
	self
		assert: self classCategoryPresenter roots last name
		equals: 'All'.
	self
		assert: self classCategoryPresenter selectedItem name
		equals: RowanClassCategoryService new nilCategoryDisplayName.
	self assert: self classListPresenter items size equals: 1.
	self
		assert: self classListPresenter items first name
		equals: 'RowanSample1'.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanSample1'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_hierarchyExpansion [

	| hierarchyModel names |
	self todo: 'Not a great test of expansion in JfPwoR. Fix later.'.
	self
		testsIssue: #issue156
		withTitle: 'Double click on hierarchy class should expand list #156'.
	self
		selectServicesNamed: (Array with: 'Globals')
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Collections';
			 substringIndex: 1;
			 yourself).
	names := self classListPresenter model collection collect: [
		         :classService | classService name ].
	self assert: (names includes: 'IdentityBag').
	self selectHierarchyTab.
	(Delay forMilliseconds: 500) wait.
	hierarchyModel := self classHierarchyPresenter model.

	self assert: hierarchyModel first name equals: 'Object'.
	
	hierarchyModel := self classHierarchyPresenter childrenFor:
		                  hierarchyModel first.
	self denyIsNil: (hierarchyModel
			 detect: [ :svc | svc name = 'Association' ]
			 ifNone: [  ]).
	self denyIsNil: (hierarchyModel
			 detect: [ :svc | svc name = 'Collection' ]
			 ifNone: [  ]).
	self assertIsNil: (hierarchyModel
			 detect: [ :svc | svc name = 'RwGsPlatform' ]
			 ifNone: [  ])
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_jfpworFindClass [

	JadeitePreferences isRowanAvailable ifTrue: [
		^ self skip: 'classes are in different packages' ].
	self projectsPresenter
		updateAfterFindClass: (RowanClassService new name: 'RwGsPlatform')
		methodService: nil
		onCompletion: [  ].
	self
		assert: self classListPresenter selectedItem name
		equals: 'RwGsPlatform'.
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'UserGlobals'.
	self
		assert: self classCategoryPresenter selectedItem data
		equals: 'Stubs'.
	self projectsPresenter
		updateAfterFindClass:
		(RowanClassService new name: 'CypressClassDefinition')
		methodService: nil
		onCompletion: [  ].
	self projectsPresenter
		updateAfterFindClass: (RowanClassService new name: 'Collection')
		methodService: nil
		onCompletion: [  ].
	
	self
		assert: self classListPresenter selectedItem name
		equals: 'Collection'.
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'Globals'.
	self
		assert: self classCategoryPresenter selectedItem data
		equals: 'Collections'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_moveMethodToCategoriesWithUnusedTemp [

	| selectedNames selectedCategories |
	self
		testsJadeiteForPharoIssue: #issue357
		title:
		'WOR: unused temp variables may results in walkback "Instances of ClassOrganizer do not support replication"'
		url: 'https://github.com/GemTalk/JadeiteForPharo/issues/357'.
	self selectRowanSample1Class.
	self projectsPresenter basicAddMethodCategory: 'targetCategory'.
	self selectCategoryNamed: 'accessing'.
	self saveMethod: 'abc  | unused |  ^#abc' in: 'RowanSample1'.
	self saveMethod: 'def  | unused |  ^#def' in: 'RowanSample1'.
	self selectCategoryNamed: 'dontCare'.
	self selectMethodsNamed: #( abc def ).
	self projectsPresenter
		moveMethods: self methodListPresenter selectedItems
		toCategory: (JadeiteCategory named: 'targetCategory').
	self
		assert: self categoryListPresenter selectedItem categoryName
		equals: 'targetCategory'.
	selectedNames := self methodListPresenter selectedItems collect: [
		                 :methodService | methodService selector ].
	self assert: selectedNames equals: #( abc def ) asOrderedCollection.
	selectedCategories := self methodListPresenter selectedItems
		                      collect: [ :methodService |
		                      methodService category ].
	self
		assert: selectedCategories
		equals: #( 'targetCategory' 'targetCategory' ) asOrderedCollection
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_nilClassCategory [
	"When selecting a class, don't reset the class category
	selection to the full class category path."

	self jadeiteTestResourceClass current
		createRowanSample1ProjectWithEmpyClassCategory.
	self
		selectServiceNamed: self rowanSampleDictionaryName
		in: self dictionaryListPresenter.
	self
		assert: self classCategoryPresenter roots last name
		equals: 'All'.

	self assert: self classListPresenter items size equals: 2.
	self assert:
		((self classListPresenter items collect: [ :ea | ea name ])
			 includes: 'RowanSample1').
	self assert:
		((self classListPresenter items collect: [ :ea | ea name ])
			 includes: 'RowanSample1Test').
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: String new;
			 substringIndex: 1;
			 yourself).
	self
		assert: self classCategoryPresenter selectedItem name
		equals: RowanClassCategoryService new nilCategoryDisplayName.
	self assert: self classListPresenter items size equals: 1.
	self
		assert: self classListPresenter items first name
		equals: 'RowanSample1'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_resetClassDefinitionTemplate [
	"selected dictionary only"

	self
		selectServiceNamed: 'RowanKernel'
		in: self dictionaryListPresenter.
	self projectsPresenter resetClassTemplate.
	self deny: self projectsPresenter classDefinitionPresenter isModified.
	self assert: ('*RowanKernel*' match:
			 self projectsPresenter classDefinitionPresenter text).

	"selected project and package"
	self selectClassCategoryNamed: 'GemStone-Interactions-Core'. "Selects GemStone"
	self projectsPresenter resetClassTemplate.
	self deny: self projectsPresenter classDefinitionPresenter isModified.
	self assert: self projectsPresenter classDefinitionPresenter text replaceLfWithCr equals: '(Object subclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	inDictionary: RowanKernel
	options: #()) category:  ''GemStone''
'.

	"selected project and class"
	self
		selectServiceNamed: 'GsInteraction'
		in: self classListPresenter.
	self projectsPresenter resetClassTemplate.
	self deny: self projectsPresenter classDefinitionPresenter isModified.
	self
		assert: self classListPresenter selectedItem name
		equals: 'GsInteraction'.
	self
		assert: self projectsPresenter classDefinitionPresenter text
		equals: self classListPresenter selectedItem template.

	"selected project and class in class hierarchy"
	self selectServiceNamed: 'GsInteractionRequest' in: self classListPresenter.
	self projectsPresenter selectClassHierarchyTab.
	self
		assert: self classHierarchyPresenter selectedItem name
		equals: 'GsInteractionRequest'.
	self projectsPresenter resetClassTemplate.
	self deny: self projectsPresenter classDefinitionPresenter isModified.
	self
		assert: self projectsPresenter classDefinitionPresenter text
		equals: self classHierarchyPresenter selectedItem template
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_resetClassDefinitionTemplate_classCategorySelected [

	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Core';
			 substringIndex: 3;
			 yourself).
	self assertTextPaneResetFor:
		self projectsPresenter classDefinitionPresenter
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_resetClassDefinitionTemplate_dictionarySelection [

	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self assertTextPaneResetFor:
		self projectsPresenter classDefinitionPresenter
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_resetClassDefinitionTemplate_noDictionarySelection [

	self dictionaryListPresenter unselectAll.
	self assertTextPaneResetFor:
		self projectsPresenter classDefinitionPresenter
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_runTestInBrowser [

	| methodService |
	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self servicesTestsLoaded ifFalse: [
		^ self skip: 'service server tests not loaded. test skipped' ].
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self
		selectServiceNamed: 'RowanAnsweringServiceTest'
		in: self classListPresenter.
	self
		selectServiceNamed: 'test_disableBreakpointsInterface'
		in: self methodListPresenter.
	methodService := self methodListPresenter selectedItem.
	self
		assert:
			(self projectsPresenter methodListPresenter displayIcon value:
				 methodService) labelGraphic
		equals: (Smalltalk ui icons iconNamed: #testNotRun).
	self projectsPresenter debugMethodTests: methodService.
	(Delay forMilliseconds: 500) wait. "arbitrary wait could be improved. "
	self
		assert:
			(self projectsPresenter methodListPresenter displayIcon value:
				 methodService) labelGraphic
		equals: (Smalltalk ui icons iconNamed: #testGreen)
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_saveClass [

	| classService |
	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self servicesTestsLoaded ifFalse: [
		^ self skip: 'service server tests not loaded. test skipped' ].
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self
		selectServiceNamed: 'RowanAnsweringServiceTest'
		in: self classListPresenter.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringServiceTest'.
	self
		jfpwor_classDefinitionFor: 'TestClass'
		superclass: 'Object'
		instVars: #( 'test_saveClass' )
		category: 'Rowan-Services-Tests'.
	self
		assert: self classListPresenter selectedItem name
		equals: 'TestClass'.
	self assert: ('Object rwSubclass: ''TestClass''*' match:
			 self projectsPresenter classDefinitionPresenter text).
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	classService := RowanClassService new
		                name: 'TestClass';
		                meta: false.
	self assert:
		(self dictionaryListPresenter selectedItem classes includes:
			 classService)
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_saveClassChangedCategory [

	| classService |
	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self servicesTestsLoaded ifFalse: [
		^ self skip: 'service server tests not loaded. test skipped' ].
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self
		selectServiceNamed: 'RowanAnsweringServiceTest'
		in: self classListPresenter.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringServiceTest'.
	self
		jfpwor_classDefinitionFor: 'TestClass'
		superclass: 'Object'
		instVars: #( 'test_saveClass' )
		category: 'Rowan-Services-Tests'.
	self
		assert: self classListPresenter selectedItem name
		equals: 'TestClass'.
	self assert: ('Object rwSubclass: ''TestClass''*' match:
			 self projectsPresenter classDefinitionPresenter text).
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	self
		assert: self classCategoryPresenter selectedItem
		equals: (RowanClassCategoryService new
				 name: 'Rowan-Services-Tests';
				 substringIndex: 3).
	classService := RowanClassService new
		                name: 'TestClass';
		                meta: false.
	self assert:
		(self dictionaryListPresenter selectedItem classes includes:
			 classService).
	"----------------Change the category and see if the category selection changes ------------------"
	self
		jfpwor_classDefinitionFor: 'TestClass'
		superclass: 'Object'
		instVars: #( 'test_saveClass' )
		category: 'Rowan-Services-Core'.
	self
		assert: self classListPresenter selectedItem name
		equals: 'TestClass'.
	self assert: ('Object rwSubclass: ''TestClass''*' match:
			 self projectsPresenter classDefinitionPresenter text).
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	self
		assert: self classCategoryPresenter selectedItem
		equals: (RowanClassCategoryService new
				 name: 'Rowan-Services-Core';
				 substringIndex: 3)
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_saveClassInHierarchy [

	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self servicesTestsLoaded ifFalse: [
		^ self skip: 'service server tests not loaded. test skipped' ].
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self
		selectServiceNamed: 'RowanAnsweringServiceTest'
		in: self classListPresenter.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringServiceTest'.
	self selectHierarchyTab.
	self
		jfpwor_classDefinitionFor: 'TestClass'
		superclass: 'Object'
		instVars: #( 'test_saveClass' )
		category: 'Rowan-Services-Tests'.
	self
		assert: self classHierarchyPresenter selectedItem name
		equals: 'TestClass'.
	self
		assert: self classCategoryPresenter selectedItem
		equals: (RowanClassCategoryService new
				 name: 'Rowan-Services-Tests';
				 substringIndex: 3;
				 yourself).
	self assert: ('Object rwSubclass: ''TestClass''*' match:
			 self projectsPresenter classDefinitionPresenter text).
	self assert: self projectsPresenter isClassDefinitionTabSelected
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_saveClassInHierarchyChangedCategory [

	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self servicesTestsLoaded ifFalse: [
		^ self skip: 'service server tests not loaded. test skipped' ].
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self
		selectServiceNamed: 'RowanAnsweringServiceTest'
		in: self classListPresenter.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringServiceTest'.
	self selectHierarchyTab.
	self
		jfpwor_classDefinitionFor: 'TestClass'
		superclass: 'Object'
		instVars: #( 'test_saveClass' )
		category: 'Rowan-Services-Tests'.
	self
		assert: self classHierarchyPresenter selectedItem name
		equals: 'TestClass'.
	self
		assert: self classCategoryPresenter selectedItem
		equals: (RowanClassCategoryService new
				 name: 'Rowan-Services-Tests';
				 substringIndex: 3;
				 yourself).
	self assert: ('Object rwSubclass: ''TestClass''*' match:
			 self projectsPresenter classDefinitionPresenter text).
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	"----------------Change the category and see if the category selection changes ------------------"
	self
		jfpwor_classDefinitionFor: 'TestClass'
		superclass: 'Object'
		instVars: #( 'test_saveClass' )
		category: 'Rowan-Services-Core'.
	self
		assert: self classHierarchyPresenter selectedItem name
		equals: 'TestClass'.
	self assert: ('Object rwSubclass: ''TestClass''*' match:
			 self projectsPresenter classDefinitionPresenter text).
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	self
		assert: self classCategoryPresenter selectedItem
		equals: (RowanClassCategoryService new
				 name: 'Rowan-Services-Core';
				 substringIndex: 3)
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_saveClassNewCategory [
	"test won't work until Rowan Stub is available. 
Even then it may not work as the test has never been successfully run"
	true ifTrue: [ ^self ].
	self selectServiceNamed: 'Globals' in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Kernel';
			 substringIndex: 1;
			 yourself).
	self selectServiceNamed: 'Array' in: self classListPresenter.
	self
		assert: self classListPresenter selectedItem name
		equals: 'Array'.
	self
		jfpwor_classDefinitionFor: 'TestClassWithNewCategory'
		superclass: 'Object'
		instVars: #( 'test_saveClassNewCategory' )
		category: 'Rowan-Services-Tests-NewCategory'.
	self
		assert: self classListPresenter selectedItem name
		equals: 'TestClassWithNewCategory'.
	self assert:
		('Object rwSubclass: ''TestClassWithNewCategory''*' match:
			 self projectsPresenter classDefinitionPresenter text).
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	self
		assert: self classCategoryPresenter selectedItem
		equals: (RowanClassCategoryService new
				 name: 'Rowan-Services-Tests-NewCategory';
				 substringIndex: 4)
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_selectClassButCategoryIsUnchanged [
	"When selecting a class, don't reset the class category
	selection to the full class category path."

	self
		selectServiceNamed: 'RowanClientServices'
		in: self dictionaryListPresenter.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Core';
			 substringIndex: 2;
			 yourself).
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'RowanClientServices'.
	self
		assert: self classCategoryPresenter selectedItem firstSubstringsToIndex
		equals: 'Rowan-Services'.
	self
		assertIsNil: self classListPresenter selectedItem. 
		
	self
		selectServiceNamed: 'RowanAnsweringService'
		in: self classListPresenter.
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'RowanClientServices'.
	self
		assert: self classCategoryPresenter selectedItem firstSubstringsToIndex
		equals: 'Rowan-Services'. "not changed to Rowan-Services-Core"
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringService'.
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_selectClassCategory [
	"basic test to just ensure class category presenter gets correct selection"

	self selectRowanAnsweringService.
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'RowanClientServices'.
	self
		assert: self classCategoryPresenter selectedItem data
		equals: 'Core'.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringService'
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_selectClassCategoryInSamePath [
	"should be able to select a new class category higher in the path
	without losing the selection"

	"in hierarchy don't lose selection""Rowan-Services""Rowan""not in hierarchy, selection cleared"

	self servicesTestsLoaded ifFalse: [
		^ self skip: 'service server tests not loaded. test skipped' ].
	self selectRowanAnsweringService.
	self
		assert: self dictionaryListPresenter selectedItem name
		equals: 'RowanClientServices'.
	self
		assert: self classCategoryPresenter selectedItem data
		equals: 'Core'.
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringService'.
	self classCategoryPresenter unselectAll.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Core';
			 substringIndex: 2;
			 yourself).
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringService'.
	self classCategoryPresenter unselectAll.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Core';
			 substringIndex: 1;
			 yourself).
	self
		assert: self classListPresenter selectedItem name
		equals: 'RowanAnsweringService'.
	self classCategoryPresenter unselectAll.
	self classCategoryPresenter selectItem:
		(RowanClassCategoryService new
			 name: 'Rowan-Services-Tests';
			 substringIndex: 3;
			 yourself).
	self assertIsNil: self classListPresenter selectedItem
]

{ #category : 'tests' }
JadeiteForPharoBrowserWithoutRowanTestCase >> test_twoBrowsersAddSameCategoryToClassAndInstance [

	self
		testsIssue: #issue418
		withTitle:
		'Navigating and category creation in class hiearchy view can''t keep class side/instance side straight'.

	self jadeiteTestResourceClass current
		createRowanSample1ProjectWithEmpyClassCategory.
	self
		selectRowanSample1Test;
		selectHierarchyTab;
		openSecondBrowser.
	(Delay forMilliseconds: 500) wait.
	self
		selectRowanSample1TestIn: secondPresenter;
		selectHierarchyTabIn: secondPresenter;
		selectClassSide;
		deny:
			(self projectsPresenter categoryListPresenter list includes:
					 'fnoodle');
		deny:
			(secondPresenter categoryListPresenter list includes: 'fnoodle').
	self assert: self projectsPresenter isClassSideSelected.
	self projectsPresenter basicAddMethodCategory: 'fnoodle'.
	self
		assert: self projectsPresenter categoryListPresenter selectedItem
		equals: 'fnoodle';
		deny:
			(secondPresenter categoryListPresenter list includes: 'fnoodle').
	self deny: secondPresenter isClassSideSelected.
	secondPresenter basicAddMethodCategory: 'fnoodle'.
	self
		assert: secondPresenter categoryListPresenter selectedItem
		equals: 'fnoodle';
		assert: (self categoryListPresenter list includes: 'fnoodle')
]
