Class {
	#name : 'JadeiteForPharoWindowBrowserTestCase',
	#superclass : 'JadeiteForPharoGUITestCase',
	#instVars : [
		'windowsBrowser'
	],
	#category : 'Jadeite-Tests',
	#package : 'Jadeite-Tests'
}

{ #category : 'support' }
JadeiteForPharoWindowBrowserTestCase >> setUp [

	super setUp.
	windowsBrowser := self waitForWindowsBrowser: [
		                  jadeiteShell openWindowsBrowser ]
]

{ #category : 'support' }
JadeiteForPharoWindowBrowserTestCase >> tearDown [

	super tearDown.
	self destroy: windowsBrowser
]

{ #category : 'tests' }
JadeiteForPharoWindowBrowserTestCase >> test_lowerAndRaiseAllWindows [

	windowsBrowser jadeiteWindowsListPresenter selectAll.
	windowsBrowser lowerJadeiteWindows.
	windowsBrowser jadeiteWindowsListPresenter items do: [ :presenter |
		self assert: presenter window isMinimized ].
	windowsBrowser raiseJadeiteWindows.
	windowsBrowser jadeiteWindowsListPresenter items do: [ :presenter |
		self assert: presenter window isMinimized not ].

	windowsBrowser pharoWindowsListPresenter selectAll.
	windowsBrowser lowerPharoWindows.
	windowsBrowser pharoWindowsListPresenter items do: [ :presenter |
		self assert: presenter window isMinimized ].
	windowsBrowser raisePharoWindows.
	windowsBrowser pharoWindowsListPresenter items do: [ :presenter |
		self assert: presenter window isMinimized not ]
]

{ #category : 'tests' }
JadeiteForPharoWindowBrowserTestCase >> test_openWindowsBrowser [

	self assert: (windowsBrowser isKindOf: JadeiteWindowsBrowser)
]

{ #category : 'tests' }
JadeiteForPharoWindowBrowserTestCase >> test_windowRemainsInListWhileDragged [
	"Dragging a window reparents it from the World to the Hand, making
	 windowsSatisfying: miss it on the next AutoRefresh cycle. The fix adds
	 hand submorphs to updateWindows so the entry stays in the list."

	| targetWindow hand |
	windowsBrowser refresh.
	targetWindow := windowsBrowser jadeiteWindowsListPresenter items
		                detect: [ :w | w label ~= windowsBrowser shellName ]
		                ifNone: [
			                ^ self skip:
				                'Need at least two Jadeite windows to test drag visibility' ].
	hand := self currentWorld currentHand.
	[
		hand grabMorph: targetWindow.
		self assert: (hand submorphs includes: targetWindow).
		windowsBrowser refresh.
		self assert:
			(windowsBrowser jadeiteWindowsListPresenter items includes: targetWindow)
	] ensure: [
		(hand submorphs includes: targetWindow) ifTrue: [
			targetWindow openInWorld ]
	]
]

{ #category : 'support' }
JadeiteForPharoWindowBrowserTestCase >> waitForWindowsBrowser: aBlock [

	| existingWindowsBrowsers newWindowsBrowsers count |
	RsrGarbageCollector maximumReclamation.
	existingWindowsBrowsers := JadeiteWindowsBrowser allInstances.
	aBlock fork.
	count := 0.
	[
	count > 100 or: [
		(newWindowsBrowsers := JadeiteWindowsBrowser allInstances
			                       asOrderedCollection) size
		> existingWindowsBrowsers size ] ] whileFalse: [
		count := count + 1.
		(Delay forMilliseconds: 1) wait ].
	newWindowsBrowsers removeAll: existingWindowsBrowsers.
	^ newWindowsBrowsers first
]
