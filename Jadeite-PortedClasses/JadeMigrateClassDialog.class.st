Class {
	#name : 'JadeMigrateClassDialog',
	#superclass : 'JadeValueDialog',
	#instVars : [
		'copyMethodsPresenter',
		'recompileSubclassesPresenter',
		'migrateInstancesPresenter',
		'removeFromClassHistoryPresenter'
	],
	#category : 'Jadeite-PortedClasses',
	#package : 'Jadeite-PortedClasses'
}

{ #category : 'public' }
JadeMigrateClassDialog >> createComponents [

	super createComponents.
	copyMethodsPresenter 				:= self add: BooleanPresenter	new name: 'copyMethods'.
	recompileSubclassesPresenter 			:= self add: BooleanPresenter	new name: 'recompileSubclasses'.
	migrateInstancesPresenter 			:= self add: BooleanPresenter	new name: 'migrateInstances'.
	removeFromClassHistoryPresenter	:= self add: BooleanPresenter	new name: 'removeFromClassHistory'.

]

{ #category : 'public' }
JadeMigrateClassDialog >> ok [

	self model value: (Dictionary new
		at: #copyMethods 						put: copyMethodsPresenter value;
		at: #recompileSubclasses			put: recompileSubclassesPresenter value;
		at: #migrateInstances 				put: migrateInstancesPresenter value;
		at: #removeFromClassHistory	put: removeFromClassHistoryPresenter value;
		yourself).
	super ok.

]

{ #category : 'public' }
JadeMigrateClassDialog >> onViewOpened [

	super onViewOpened.
	copyMethodsPresenter 				value: true.
	recompileSubclassesPresenter 			value: true.
	migrateInstancesPresenter 			value: false.
	removeFromClassHistoryPresenter value: false.

]
