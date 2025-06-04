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
