"
A place for service tests that involve numerous services
"
Class {
	#name : 'JadeiteForPharoGeneralRowanServiceTestCase',
	#superclass : 'JadeiteForPharoRowanServiceTestCase',
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'tests' }
JadeiteForPharoGeneralRowanServiceTestCase >> test_rowanServiceIsAbstract [
	"RowanService is the abstract service class.
	Pharo browsers display abstract classes in italics.
	The browser determines if a class is abstract if it is marked abstract
	or has `subclassResponsibility` methods. "

	self assert: RowanService isAbstract.
	RowanService subclasses do: [ :subclass |
		self deny: subclass isAbstract ]
]

{ #category : 'tests' }
JadeiteForPharoGeneralRowanServiceTestCase >> test_rowanServiceSubclassesDoNotImplementSubclassResponsibility [
	"RowanService is the abstract service class.
	Pharo browsers display abstract classes in italics.
	The browser determines if a class is abstract if it is marked abstract
	or has `subclassResponsibility` methods."

	| subclassResponsibilitySenders |
	subclassResponsibilitySenders := SystemNavigation new allCallsOn:
		                                 #subclassResponsibility.
	subclassResponsibilitySenders do: [ :compiledMethod |
		self deny:
			(RowanService subclasses includes: compiledMethod methodClass) ]
]

{ #category : 'tests' }
JadeiteForPharoGeneralRowanServiceTestCase >> test_subclassesOfRowanServiceImplementSubclassResponsibility [
	"If a subclass inherits a method that calls subclassResponsibility,
	that class is shown in italics as abstract in the Pharo browser. 
	Sometimes that's difficult to find if you're not sure what to look for.
	Hopefully, this test will catch those in the future."

	| subclassResponsibilitySenders rowanServiceSubclassResponsibilitySenders directSubclasses |
	subclassResponsibilitySenders := SystemNavigation new allCallsOn:
		                                 #subclassResponsibility.
	rowanServiceSubclassResponsibilitySenders := subclassResponsibilitySenders
		                                             select: [
		                                             :compiledMethod |
		                                             compiledMethod
			                                             methodClass
		                                             = RowanService ].
	directSubclasses := RowanService subclasses.

	rowanServiceSubclassResponsibilitySenders do: [ :compiledMethod |
		directSubclasses do: [ :aSubclass |
			self assert:
				(aSubclass methodDictionary keys includes: compiledMethod selector) ] ]
]

{ #category : 'tests' }
JadeiteForPharoGeneralRowanServiceTestCase >> test_templateClassName [
	"rsr requirements"

	(SystemNavigation new allImplementorsOf: #templateClassName) do: [
		:compiledMethod |
		| theClass |
		theClass := compiledMethod methodClass.
		(theClass allSuperclasses includes: RowanService class) ifTrue: [
			| soleInstance |
			soleInstance := theClass soleInstance.
			self deny: (soleInstance name last: 6) equals: 'Client'.
			self
				assert: soleInstance templateClassName
				equals: soleInstance name ] ]
]
