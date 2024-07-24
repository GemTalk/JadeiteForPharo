Class {
	#name : 'RowanBrokenPromise',
	#superclass : 'RsrBrokenPromise',
	#category : 'Jadeite-SupportClasses',
	#package : 'Jadeite-SupportClasses'
}

{ #category : 'accessing' }
RowanBrokenPromise >> defaultAction [

	| workspace |
	self halt. 
	workspace := JadeiteApplication openOn: #SpTextPresenter. 
	workspace theInstance text: ((reason class canUnderstand: #stack) ifTrue:[
	reason stack] 
	ifFalse:[reason class name]).
	(reason class canUnderstand: #stack) ifTrue:[
		workspace theInstance window title: reason messageText.  
	workspace theInstance text: reason stack] 
	ifFalse:[workspace theInstance window title: reason class name. workspace theInstance text: reason class name].
	workspace theInstance addStyle: 'jadedRedBackgroundColor'.
	"[ Processor activeProcess terminate ] ensure: [ 
		DefaultExecutionEnvironment beActiveDuring: [ 
			UIManager default spawnNewProcess ] ]"
]
