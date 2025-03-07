Extension { #name : 'WorldState' }

{ #category : '*Jadeite-BaseExtensions' }
WorldState >> adjustWakeupTimes: now [
	"Fix the wakeup times in my step list. This is necessary when this world has been restarted after a pause, say because some other view had control, after a snapshot, or because the millisecond clock has wrapped around. (The latter is a rare occurrence with a 32-bit clock!)"

	| deltaTime |
	deltaTime := now - lastStepTime.
	stepList do: [ :entry | "work around pharo bug where entry is nil"
		(entry class canUnderstand: #scheduledTime) ifTrue: [
			entry scheduledTime: entry scheduledTime + deltaTime ] ].
	lastStepTime := now
]
