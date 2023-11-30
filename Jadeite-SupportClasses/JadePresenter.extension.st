Extension { #name : 'JadePresenter' }

{ #category : '*Jadeite-SupportClasses' }
JadePresenter class >> waitForAnswer: thingThatCanAnswer [
	| theAnswer deferredValue thisProcess |
	deferredValue := [thingThatCanAnswer answer] deferredValue.
	thisProcess := Processor activeProcess.
	
	[
	[[deferredValue hasValue not and: [thingThatCanAnswer isDeafObject not]]
		whileTrue: [(Delay forMilliseconds: 1) wait]]
			ensure: 
				[SessionManager current inputState main: Processor activeProcess.
				thingThatCanAnswer isDeafObject
					ifTrue: [thisProcess terminate]
					ifFalse: [[thisProcess resume: nil] on: Error do: [:ex | ]]]]
			fork.
	Processor suspendActive.
	theAnswer := [deferredValue value] on: Error
				do: 
					[:ex |
					ex messageText = 'DeferredValue terminated prematurely'
						ifTrue: [nil]
						ifFalse: 
							[thingThatCanAnswer
								getProcessList;
								update.	"should be a debugger so update"
							self waitForAnswer: thingThatCanAnswer]].
	^theAnswer
]
