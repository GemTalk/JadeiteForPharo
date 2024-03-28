Class {
	#name : 'JadeiteMenuItemPresenter',
	#superclass : 'SpMenuItemPresenter',
	#category : 'Jadeite-SupportClasses'
}

{ #category : 'api' }
JadeiteMenuItemPresenter >> action [
	"instead of directly executing the action, cue the action block on Jadeite's queue
	which is semaphore controlled."

	^ [ action schedule ]
]
