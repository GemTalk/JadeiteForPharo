Class {
	#name : 'JadeiteForPharoRowanServiceTestCase',
	#superclass : 'JadeiteForPharoHeadlessTestCase',
	#instVars : [
		'updater'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoRowanServiceTestCase >> setUp [ 

	super setUp. 
	updater := RowanServiceUpdater current. 
	session := GciSession current. 
]
