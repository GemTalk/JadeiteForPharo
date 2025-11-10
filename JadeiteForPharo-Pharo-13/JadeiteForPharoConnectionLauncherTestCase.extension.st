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
