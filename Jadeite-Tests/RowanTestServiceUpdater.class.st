Class {
	#name : 'RowanTestServiceUpdater',
	#superclass : 'RowanServiceUpdater',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'instance creation' }
RowanTestServiceUpdater class >> installTestUpdater [
	"RowanTestServiceUpdater installTestUpdater"
	self adoptInstance: self current
]

{ #category : 'commands' }
RowanTestServiceUpdater >> basicIssueCommand: service [
	"Don't block the morphic process.
	Any sending process has to use completion blocks"

	| sem processingCommand |
	sem := Semaphore new.
	processingCommand := true.
	Processor activeProcess name = 'Morphic UI Process' ifTrue: [
		[ MorphicRenderLoop new doOneCycleWhile: [ processingCommand ] ]
			fork ].
	[
	[ self _basicIssueCommand: service ] ensure: [
		processingCommand := false.
		sem signal ] ] fork.
	sem wait
]
