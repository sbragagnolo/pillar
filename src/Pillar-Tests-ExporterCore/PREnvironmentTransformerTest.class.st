Class {
	#name : #PREnvironmentTransformerTest,
	#superclass : #PRNodeTransformerTest,
	#category : #'Pillar-Tests-ExporterCore-Transformers'
}

{ #category : #private }
PREnvironmentTransformerTest >> actualClass [
	^ PREnvironmentTransformer
]

{ #category : #'tests environment' }
PREnvironmentTransformerTest >> testTransformationBasicTextInsideAnEnvironment [
	| input expected |
	input := PRDocument new
		add: (PRBeginEnvironmentAnnotation named: 'card');
		add: (PRParagraph with: (PRText content: 'First paragraph inside environment') yourself);
		add: (PRParagraph with: (PRText content: 'Second paragraph inside environment') yourself);
		add: (PREndEnvironmentAnnotation named: 'card');
		yourself.
	expected := PRDocument new
		add: ((PREnvironment named: 'card')
						add: (PRParagraph with: (PRText content: 'First paragraph inside environment') yourself);
						add: (PRParagraph with: (PRText content: 'Second paragraph inside environment') yourself);
						yourself);
		yourself.
	self assert: (self executePhase: input) equals: expected
]

{ #category : #tests }
PREnvironmentTransformerTest >> testTransformationBeginningColumnsWithoutEnding [
	| input |
	input := PRDocument
		withAll:
			{PRBeginColumnsAnnotation new.
			(PRColumnAnnotation
				withParameters: (
					PRParameters withAll: { 
						PRParameter 
							keyNode: (PRParameterKey named: 'width')
							valueNode: (PRParameterValue value: 100) })).
			(PRText content: 'Foo')}.
	self should: [ self executePhase: input ] raise: PRError whoseDescriptionIncludes: 'Missing end' description: 'Code must detect the absence of end annotation'
]

{ #category : #tests }
PREnvironmentTransformerTest >> testTransformationEndColumnsWithoutBeginning [
	| input |
	input := PRDocument with: PREndColumnsAnnotation new.
	self should: [ (self executePhase: input with: self configuration) ] raise: PRError whoseDescriptionIncludes: 'out of a column environment' description: 'Code should detect a missing annotation'
]

{ #category : #'tests environment' }
PREnvironmentTransformerTest >> testTransformationInAbsenceOfEnvironment [
	"there is not environment so nothing happens."
	| input |
	input := PRDocument new
		add: (PRParagraph new
						add: (PRText content: 'Foo');
						yourself);
		add: (PRParagraph with: (PRText content: 'Bar') yourself);
		yourself.
	self assert: (self executePhase: input with: self configuration) equals: input
]

{ #category : #tests }
PREnvironmentTransformerTest >> testTransformationOnColumn [
	| input expected |
	input := PRDocument new
		add: PRBeginColumnsAnnotation new;
		add: (PRColumnAnnotation withParameters: (
					PRParameters withAll: { 
						PRParameter 
							keyNode: (PRParameterKey named: 'width')
							valueNode: (PRParameterValue value: '100') }));
		add:	(PRParagraph new
						add: (PRText content: 'Foo');
						yourself);
		add:
				PREndColumnsAnnotation new;
		yourself.
	expected := PRDocument new
		add:
				(PRColumnEnvironment new
						add:
							((PRColumn width: '100')
								add:
										(PRParagraph new
												add: (PRText content: 'Foo');
												yourself);
								yourself));
		yourself.
	self assert: (self executePhase: input) equals: expected
]

{ #category : #tests }
PREnvironmentTransformerTest >> testTransformationTwoColumns [
	| input expected |
	input := PRDocument new
		add: PRBeginColumnsAnnotation new;
		add:
			(PRColumnAnnotation
				withParameters: (
					PRParameters withAll: { 
						PRParameter 
							keyNode: (PRParameterKey named: 'width')
							valueNode: (PRParameterValue value: '50') }));
		add:
			(PRParagraph new
				add: (PRText content: 'Foo');
				yourself);
		add:
			(PRColumnAnnotation
				withParameters: (
					PRParameters withAll: { 
						PRParameter 
							keyNode: (PRParameterKey named: 'width')
							valueNode: (PRParameterValue value: '50') }) yourself);
		add:
			(PRParagraph new
				add: (PRText content: 'Bar');
				yourself);
		add: PREndColumnsAnnotation new;
		yourself.
	expected := PRDocument new
		add:
			(PRColumnEnvironment new
				add:
					((PRColumn width: '50')
						add:
							(PRParagraph new
								add: (PRText content: 'Foo');
								yourself));
				add:
					((PRColumn width: '50')
						add:
							(PRParagraph new
								add: (PRText content: 'Bar');
								yourself);
						yourself));
		yourself.
	self assert: (self executePhase: input with: self configuration) equals: expected
]

{ #category : #tests }
PREnvironmentTransformerTest >> testTransformationWithColumnWithoutColumns [
	| input |
	input := PRDocument new
		add: PRColumnAnnotation new;
		add:
			(PRParagraph new
				add: (PRText content: 'Foo');
				yourself);
		add: PREndColumnsAnnotation new;
		yourself.
	self
		should: [ self executePhase: input ]
		raise: PRError
		whoseDescriptionIncludes: 'not inside a column environment'
		description: 'Code is missing a check'
]

{ #category : #tests }
PREnvironmentTransformerTest >> testTransformationWithColumnsInColumns [
	| input |
	input := PRDocument new
		add:
				PRBeginColumnsAnnotation new;
		add:
				PRBeginColumnsAnnotation new;
		add:
				PREndColumnsAnnotation new;
		add:
				PREndColumnsAnnotation new;
		yourself.
	self should: [ self executePhase: input ] raise: PRError whoseDescriptionIncludes: 'close a columns environment' description: 'Code is missing a check'
]

{ #category : #tests }
PREnvironmentTransformerTest >> testTransformationWithContentInsideColumnsBeforeColumn [
	| input expected |
	input := PRDocument new
		add:
				PRBeginColumnsAnnotation new;
		add: (PRParagraph with: (PRText content: 'Foo') yourself);
		add:
				(PRColumnAnnotation withParameters: (
					PRParameters withAll: { 
						PRParameter 
							keyNode: (PRParameterKey named: 'width')
							valueNode: (PRParameterValue value: '100') }));
		add: (PRParagraph with: (PRText content: 'Bar') yourself);
		add:
				PREndColumnsAnnotation new;
		yourself.
	expected := PRDocument new
		add:
				(PRColumnEnvironment new
						add: (PRParagraph with: (PRText content: 'Foo') yourself);
						add: ((PRColumn width: '100') add: (PRParagraph with: (PRText content: 'Bar') yourself) yourself);
						yourself);
		yourself.
	self assert: (self executePhase: input) equals: expected
]

{ #category : #tests }
PREnvironmentTransformerTest >> testTransformationWithNonGroupItemAtTopLevel [
	| input expected |
	"This test makes sure that a document item which is not a document group can be a direct child of a column"
	input := PRDocument new
		add: PRBeginColumnsAnnotation new;
		add:
			(PRColumnAnnotation
				withParameters: (
					PRParameters withAll: { 
						PRParameter 
							keyNode: (PRParameterKey named: 'width')
							valueNode: (PRParameterValue value: '100') }));
		add: PRHorizontalRule new;
		add: PREndColumnsAnnotation new;
		yourself.
	expected := PRDocument new
		add:
			(PRColumnEnvironment new
				add:
					((PRColumn width: '100')
						add: PRHorizontalRule new;
						yourself));
		yourself.
	self assert: (self executePhase: input) equals: expected
]