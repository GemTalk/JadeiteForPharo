Extension { #name : 'WorldState' }

{ #category : '*Jadeite-BaseExtensions' }
WorldState >> adjustWakeupTimes: now [
	"Fix the wakeup times in my step list. This is necessary when this world has been restarted after a pause, say because some other view had control, after a snapshot, or because the millisecond clock has wrapped around. (The latter is a rare occurrence with a 32-bit clock!)"

	"JfP change - entry can be nil. If nil, your image will get into infinitely 
	recursive errors. Try to work around that and hope the state will be fixed
	on the next pass."

	| deltaTime |
	deltaTime := now - lastStepTime.
	stepList do: [ :entry |
		| theEntry |
		theEntry := entry. "entry seems to become nil anytime even though it's a parameter"
		theEntry ifNotNil: [
			theEntry scheduledTime: theEntry scheduledTime + deltaTime ] ].
	lastStepTime := now
]

{ #category : '*Jadeite-BaseExtensions' }
WorldState >> runLocalStepMethodsIn: aWorld [
	"Run morph 'step' methods (LOCAL TO THIS WORLD) whose time has come. Purge any morphs that are no longer in this world.
	ar 3/13/1999: Remove buggy morphs from the step list so that they don't raise repeated errors."

	| now morphToStep stepTime priorWorld |
	now := Time millisecondClockValue.
	priorWorld := ActiveWorld.
	ActiveWorld := aWorld.
	self triggerAlarmsBefore: now.
	stepList isEmpty ifTrue: [
		ActiveWorld := priorWorld.
		^ self ].
	(now < lastStepTime or: [ now - lastStepTime > 5000 ]) ifTrue: [
		self adjustWakeupTimes: now ]. "clock slipped"
	[
	stepList isEmpty not and: [
		stepList
			ifNil: [ "<<<<<< JfP override. stepList can be nil apparently."
			^ self ]
			ifNotNil: [ stepList first scheduledTime < now ] ] ] whileTrue: [
		lastStepMessage := stepList removeFirst.
		lastStepMessage ifNil: [ ^ self ]. "<<<<<< JfP override."
		morphToStep := lastStepMessage receiver.
		(morphToStep shouldGetStepsFrom: aWorld) ifTrue: [
			lastStepMessage value: now.
			lastStepMessage ifNotNil: [
				stepTime := lastStepMessage stepTime ifNil: [
					            morphToStep stepTime ].
				lastStepMessage scheduledTime: now + (stepTime max: 1).
				stepList add: lastStepMessage ] ].
		lastStepMessage := nil ].
	lastStepTime := now.
	ActiveWorld := priorWorld
]

{ #category : '*Jadeite-BaseExtensions' }
WorldState >> stopStepping: aMorph [
	"Remove the given morph from the step list."

	lastStepMessage ifNotNil: [
		lastStepMessage receiver == aMorph ifTrue: [ lastStepMessage := nil ] ].
	stepList removeAll: (stepList select: [ :stepMsg |
		"<<<<<< JfP override. stepMsg can be nil."

			 stepMsg ifNil: [ true ] ifNotNil: [ stepMsg receiver == aMorph ] ])
]

{ #category : '*Jadeite-BaseExtensions' }
WorldState >> stopStepping: aMorph selector: aSelector [
	"Remove the given morph from the step list."

	lastStepMessage ifNotNil: [
		(lastStepMessage receiver == aMorph and: [
			 lastStepMessage selector == aSelector ]) ifTrue: [
			lastStepMessage := nil ] ].
	stepList removeAll: (stepList select: [ :stepMsg |
			 stepMsg
				 ifNil: [ true ]
				 ifNotNil: [
				 stepMsg receiver == aMorph and: [ stepMsg selector == aSelector ] ] "<<<<<< JfP override. stepMsg can be nil." ])
]
