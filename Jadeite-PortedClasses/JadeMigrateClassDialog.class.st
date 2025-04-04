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
