Class {
	#name : 'JadeiteForPharoRowanMethodServiceTestCase',
	#superclass : 'JadeiteForPharoRowanServiceTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoRowanMethodServiceTestCase >> setUp [

	updater := RowanServiceUpdater current.
	JadeiteConnectionProfile connectionProfile disconnect.
	JadeiteConnectionProfile connectionProfile connect.
	session := GciSession current
]

{ #category : 'tests' }
JadeiteForPharoRowanMethodServiceTestCase >> test_methodServiceReplication [
	"test unreported bug & fix in https://github.com/GemTalk/JadeiteForPharo/commit/ea30f5038e0f5e46592800a6af7379e3a54f67ff
	RowanMethodServiceClient>>#shouldReplicateInstVarAtIndex:newService:
	...
	...
	^ self indexOfSourceInstVar = index and: [
		  (newService instVarAt: index) notNil ]  <<<< WRONG, didn't replicate some values.  

	(self indexOfSourceInstVar = index and: [
		 (newService instVarAt: index) notNil ]) ifTrue: [ ^ false ].
	^ true   <<<<< RIGHT
	"

	| service replicatedService |
	service := RowanMethodService new
		           selector: #answer;
		           className: 'RowanAnsweringService';
		           meta: false.
	updater updateService: service session: session onCompletion: [  ].
	replicatedService := RowanMethodService new
		                     selector: #answer;
		                     className: 'RowanAnsweringService';
		                     meta: false.
	replicatedService replicateFrom: service.
	1 to: replicatedService class instSize do: [ :index |
		index <= 5 ifFalse: [
			index = 44 ifFalse: [
				self
					assert: (replicatedService instVarAt: index)
					equals: (service instVarAt: index) ] "semaphore" ] ]
]
