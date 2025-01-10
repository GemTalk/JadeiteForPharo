Class {
	#name : 'JadeiteWindow',
	#superclass : 'SpWindow',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'testing' }
JadeiteWindow >> canDiscardEdits [
	"the presenter is asked first. If it says 'no' then I shouldn't override that. 
	See SpWindowPresenter>>okToChange"
	
	^false 
]

{ #category : 'icons' }
JadeiteWindow >> taskbarIconName [

	^#smallPushpin 
]
