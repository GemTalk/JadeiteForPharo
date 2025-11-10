Extension { #name : 'JadeiteForPharoConnectionLauncherTestCase' }

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteForPharoConnectionLauncherTestCase >> test_exportConnectionProfile [

	fileRef := self testConnectionFileReference.
	self deny: fileRef exists.
	[
		[ launcher exportProfile ]
			on: ProvideAnswerNotification
			do: [ :ex | ex resume: fileRef ].
		self assert: fileRef exists ] ensure: [
			fileRef delete.
			self deny: fileRef exists ]
]

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteForPharoConnectionLauncherTestCase >> test_importConnectionProfile [
	"not much of a test but at least confirm that #importProfileFile
	is exercised by a test to catch basic failures"

	| answer |
	[ answer := launcher importProfileFile ]
		on: ProvideAnswerNotification
		do: [ :ex | ex resume: 'fakePath' ].
	self assert: answer equals: 'fakePath'
]

{ #category : '*JadeiteForPharo-Pharo-13' }
JadeiteForPharoConnectionLauncherTestCase >> test_importConnectionProfileNoLastImportDirectory [

	| answer lastImportDirectory |
	lastImportDirectory := (JadeiteConnectionLauncher bindingOf:
		                        #LastImportDirectory) value.
	JadeiteConnectionLauncher lastImportDirectory: nil.
	[
		[ answer := launcher importProfileFile ]
			on: ProvideAnswerNotification
			do: [ :ex | ex resume: 'fakePath' ].
		self assert: answer equals: 'fakePath' ] ensure: [
		JadeiteConnectionLauncher lastImportDirectory: lastImportDirectory ]
]
