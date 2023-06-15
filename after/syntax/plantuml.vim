syntax keyword c4SystemElement Person Person_Ext System SystemDb SystemQueue System_Ext SystemDb_Ext SystemQueue_Ext Boundary Enterprise_Boundary System_Boundary
syntax keyword c4ContainerElement Container ContainerDb ContainerQueue Container_Ext ContainerDb_Ext ContainerQueue_Ext Container_Boundary
syntax keyword c4ComponentElement Component ComponentDb ComponentQueue Component_Ext ComponentDb_Ext ComponentQueue_Ext
syntax keyword c4DeploymentElement Deployment_Node Node Node_L Node_R
syntax keyword c4RelElement Rel BiRel Rel_U Rel_Up BiRel_U BiRel_Up Rel_D Rel_Down BiRel_D BiRel_Down Rel_L Rel_Left BiRel_L BiRel_Left Rel_R Rel_Right BiRel_R BiRel_Right
syntax keyword c4LayoutElement Lay_U Lay_Up Lay_D Lay_Down Lay_L Lay_Left Lay_R Lay_Right Lay_Distance
syntax keyword c4LayoutElement LAYOUT_TOP_DOWN LAYOUT_LEFT_RIGHT LAYOUT_LANDSCAPE LAYOUT_WITH_LEGEND SHOW_LEGEND SHOW_FLOATING_LEGEND LEGEND LAYOUT_AS_SKETCH SET_SKETCH_STYLE HIDE_STEREOTYPE HIDE_PERSON_SPRITE SHOW_PERSON_SPRITE SHOW_PERSON_PORTRAIT SHOW_PERSON_OUTLINE
syntax keyword c4Tag AddElementTag AddRelTag AddBoundaryTag AddPersonTag AddExternalPersonTag AddSystemTag AddExternalSystemTag AddComponentTag AddExternalComponentTag AddContainerTag AddExternalContainerTag AddNodeTag
syntax keyword c4Style UpdateElementStyle UpdateRelStyle UpdateBoundaryStyle UpdateContainerBoundaryStyle UpdateSystemBoundaryStyle UpdateEnterpriseBoundaryStyle RoundedBoxShape EightSidedShape DashedLine DottedLine BoldLine
syntax keyword c4Parameter $bgColor $borderColor $descr $fontColor $fontName $footerText $footerWarning $legendSprite $legendText $lineColor $lineStyle $link $shadowing $shape $sprite $tags $techn $textColor $type $warningColor

syntax region c4Constructor start=/(/ end=/)/ contains=c4Parameter,plantumlString,plantumlColor,c4Constructor

hi def link c4SystemElement Function
hi def link c4ContainerElement Function
hi def link c4ComponentElement Function
hi def link c4DeploymentElement Function
hi def link c4RelElement Keyword
hi def link c4LayoutElement Macro
hi def link c4Tag Tag
hi def link c4Style Tag
hi def link c4Parameter Constant
