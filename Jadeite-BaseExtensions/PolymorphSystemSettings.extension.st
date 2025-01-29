Extension { #name : 'PolymorphSystemSettings' }

{ #category : '*Jadeite-BaseExtensions' }
PolymorphSystemSettings class >> windowPositionStrategySettingsOn: aBuilder [
	<systemsettings>
	(aBuilder pickOne: #usedStrategy)
		label: 'Window position strategy';
		parent: #windows;
		target: RealEstateAgent;
		default: #cascadeFor:initialExtent:world:;
		domainValues: {'Reverse Stagger' -> #staggerFor:initialExtent:world:. 'Cascade' -> #cascadeFor:initialExtent:world:. 'Standard' -> #standardFor:initialExtent:world:. 'Cursor' -> #cursorPointFor:initialExtent:world:.};
		description: 'If Reversed Stagger, windows are placed in free space,
if Cascade, windows are placed in cascade based on current active window or based on cursor position.'
]
