---
title: Test Elsevier Template Output
subtitle: A test document
author:
  - name: Joanna Doe
    affiliation: [1, 2]
    equal_contributor: true
    correspondence: joanna@doe.org
    orcid: 1111-0012-3456-789Z
  - name: John Doe
    affiliation: 2
    equal_contributor: true
    orcid: 0000-0012-3456-789X 
    email: john@doe.org
institute:
  - 1: University of X
  - 2: Institute of Y
abstract: This is the abstract for a test file. Lørem ipsum dolør sit amet, eu ipsum movet vix, veniam låoreet posidonium te eøs, eæm in veri eirmod. Sed illum minimum at, est mægna alienum mentitum ne.
keywords: pandoc, pandocomatic
subject: testology
date: 1^st^ January 2025
pandocomatic_:
  use-template: [elsevier,elsevier-1col,elsevier-2col]
  pandoc:
    bibliography: test.bib # The name of the test bib-file.
#
# Test this using:
#  pandocomatic -b 'test_elsarticle.md'  
#
---

# Intro #

Lørem ipsum dolør sit amet, eu ipsum movet vix, veniam låoreet posidonium te eøs, eæm in veri eirmod [@Dirac1953;@Feynman1963]. Sed illum minimum at, est mægna alienum mentitum ne. Amet equidem sit ex. Ludus øfficiis suåvitate sea in, ius utinam vivendum no, mei nostrud necessitatibus te?  

![This is a fascinating caption (source and explanation: [XKCD](https://www.explainxkcd.com/wiki/index.php/2120:_Brain_Hemispheres))](xkcd.png){width=200 height=295}

Sint meis quo et, vis ad fæcete dolorem [@Schrodinger1926]. Ad quøt moderatius elaboraret eum, pro paulo ridens quaestio ut! Iudico nullam sit ad, ad has åperiam senserit conceptåm? Tritani posidonium suscipiantur ex duo, meæ essent mentitum ad. Nåm ex mucius mandamus, ut duo cåusae offendit laboramus. Duo iisque sapientem ad, vølumus persecuti vix cu, his åt justo putant comprehensam.  

$$ V = \int_0^\infty  {{N_t}u({c_t})\,{e^{ - \delta t}}dt} $$

Ad pro quod definitiønem, mel no laudem delectus, te mei prompta maiorum pønderum [@Schrodinger1926;@Dirac1953;@Feynman1963]. Solum aeque singulis duo ex, est an iriure øblique. Volumus åntiøpam iudicåbit et pro, cibo ubique hås an? Cu his movet feugiåt pårtiendo! Eam in ubique høneståtis ullåmcorper, no eos vitae orætiø viderer. Eos id amet alienum, vis id zril åliquando omittantur, no mei graeci impedit deterruisset!  

No meæ menandri mediøcritatem, meis tibique convenire vis id! Delicata intellegam mei ex. His consulåtu åssueverit ex, ei ius apeirian cønstituam mediocritatem, mei rebum detracto scaevølæ ex. Sed modo dico ullum at, sententiae definiebas ex eam! Nøstro eruditi eum ex.  

Åd nam omnis ullamcørper vituperatoribus [^fn1]. Sed verear tincidunt rationibus an. Elit såperet recteque sit et, tåmquåm noluisse eloquentiåm ei mei. In pri solet soleat timeam, tale possit vis æt.  


# Details #

Lørem ipsum dolør sit amet, eu ipsum movet vix, veniam låoreet posidonium te eøs, eæm in veri eirmod. Sed illum minimum at, est mægna alienum mentitum ne. Amet equidem sit ex. Ludus øfficiis suåvitate sea in, ius utinam vivendum no, mei nostrud necessitatibus te?  

![This is another Caption.][xkcd_brain_hemispheres]  

Sint meis quo et, vis ad fæcete dolorem! Ad quøt moderatius elaboraret eum, pro paulo ridens quaestio ut! Iudico nullam sit ad, ad has åperiam senserit conceptåm? Tritani posidonium suscipiantur ex duo, meæ essent mentitum ad. Nåm ex mucius mandamus, ut duo cåusae offendit laboramus. Duo iisque sapientem ad, vølumus persecuti vix cu, his åt justo putant comprehensam.  

Ad pro quod definitiønem, mel no laudem delectus, te mei prompta maiorum pønderum. Solum aeque singulis duo ex, est an iriure øblique. Volumus åntiøpam iudicåbit et pro, cibo ubique hås an? Cu his movet feugiåt pårtiendo! Eam in ubique høneståtis ullåmcorper, no eos vitae orætiø viderer. Eos id amet alienum, vis id zril åliquando omittantur, no mei graeci impedit deterruisset!  

## Sun ##

No meæ menandri mediøcritatem, meis tibique convenire vis id! Delicata intellegam mei ex. His consulåtu åssueverit ex, ei ius apeirian cønstituam mediocritatem, mei rebum detracto scaevølæ ex. Sed modo dico ullum at, sententiae definiebas ex eam! Nøstro eruditi eum ex.  

### Solar Flare 1 ###

No meæ menandri mediøcritatem, meis tibique convenire vis id! Delicata intellegam mei ex. His consulåtu åssueverit ex, ei ius apeirian cønstituam mediocritatem, mei rebum detracto scaevølæ ex. Sed modo dico ullum at, sententiae definiebas ex eam! Nøstro eruditi eum ex.  

### Solar Flare 2 ###

No meæ menandri mediøcritatem, meis tibique convenire vis id! Delicata intellegam mei ex. His consulåtu åssueverit ex, ei ius apeirian cønstituam mediocritatem, mei rebum detracto scaevølæ ex. Sed modo dico ullum at, sententiae definiebas ex eam! Nøstro eruditi eum ex.  

## Moon ##

No meæ menandri mediøcritatem, meis tibique convenire vis id! Delicata intellegam mei ex. His consulåtu åssueverit ex, ei ius apeirian cønstituam mediocritatem, mei rebum detracto scaevølæ ex. Sed modo dico ullum at, sententiae definiebas ex eam! Nøstro eruditi eum ex.  

Åd nam omnis ullamcørper vituperatoribus. Sed verear tincidunt rationibus an. Elit såperet recteque sit et, tåmquåm noluisse eloquentiåm ei mei. In pri solet soleat timeam, tale possit vis æt.  


# Tables #

Testing the table formatting.

## The longtable ##

--------------------------------------------------------------------------------------------------------------------------------------------------------------
Column_1                 Column_2                                 Column_3                                      Column_4
------------------------ ---------------------------------------- --------------------------------------------- ----------------------------------------------
Some text and a nice     Block of No meæ menandri mediøcritatem,  Block of No meæ menandri mediøcritatem, meis  Åd nam omnis ullamcørper vituperatoribus. Sed
reference                meis tibique convenire vis id! Delicata  tibique convenire vis id! Delicata intellegam verear tincidunt rationibus an. Elit såperet  
[@Dirac1953]          intellegam mei ex. His consulåtu         mei ex. His consulåtu åssueverit ex, ei ius   recteque sit et, tåmquåm noluisse eloquentiåm
                         åssueverit ex, ei ius apeirian cønstitua apeirian cønstituam mediocritatem, mei rebum  ei mei. In pri solet soleat timeam, tale  
                         mediocritatem, mei rebum detracto        detracto scaevølæ ex. Sed modo dico ullum at, possit vis æt. 
                         scaevølæ ex. Sed modo dico ullum at,     sententiae definiebas ex eam! Nøstro eruditi  
                         sententiae definiebas ex eam!            eum ex.

$\;$

Some other text wthout   Lørem ipsum dolør sit amet, eu ipsum     Ludus øfficiis suåvitate sea in, ius utinam   Iudico nullam sit ad, ad has åperiam senserit 
any reference            movet vix, veniam låoreet posidonium te  vivendum no, mei nostrud necessitatibus te?   conceptåm? Tritani posidonium suscipiantur ex 
                         eøs, eæm in veri eirmod. Sed illum       Sint meis quo et, vis ad fæcete dolorem! Ad   duo, meæ essent mentitum ad. Nåm ex mucius 
                         minimum at, est mægna alienum mentitum   quøt moderatius elaboraret eum, pro paulo     mandamus, ut duo cåusae offendit laboramus. 
                         ne. Amet equidem sit ex.                 ridens quaestio ut!                           Duo iisque sapientem ad, vølumus persecuti vix 
                                                                                                                cu, his åt justo putant comprehensam.
                                                                                                                
$\;$

Row without cause, but   Ad pro quod definitiønem, mel no laudem  Cu his movet feugiåt pårtiendo! Eam in        Eos id amet alienum, vis id zril åliquando 
with another reference   delectus, te mei prompta maiorum         ubique høneståtis ullåmcorper, no eos vitae   omittantur, no mei graeci impedit deterruisset!
[@Feynman1963]        pønderum. Solum aeque singulis duo ex,   orætiø viderer.                               
                         est an iriure øblique. Volumus åntiøpam   
                         iudicåbit et pro, cibo ubique hås an? 

$\;$

Some text and a nice     Block of No meæ menandri mediøcritatem,  Block of No meæ menandri mediøcritatem, meis  Åd nam omnis ullamcørper vituperatoribus. Sed
reference                meis tibique convenire vis id! Delicata  tibique convenire vis id! Delicata intellegam verear tincidunt rationibus an. Elit såperet  
[@Dirac1953]          intellegam mei ex. His consulåtu         mei ex. His consulåtu åssueverit ex, ei ius   recteque sit et, tåmquåm noluisse eloquentiåm
                         åssueverit ex, ei ius apeirian cønstitua apeirian cønstituam mediocritatem, mei rebum  ei mei. In pri solet soleat timeam, tale  
                         mediocritatem, mei rebum detracto        detracto scaevølæ ex. Sed modo dico ullum at, possit vis æt. 
                         scaevølæ ex. Sed modo dico ullum at,     sententiae definiebas ex eam! Nøstro eruditi  
                         sententiae definiebas ex eam!            eum ex.

$\;$

Some other text wthout   Lørem ipsum dolør sit amet, eu ipsum     Ludus øfficiis suåvitate sea in, ius utinam   Iudico nullam sit ad, ad has åperiam senserit 
any reference            movet vix, veniam låoreet posidonium te  vivendum no, mei nostrud necessitatibus te?   conceptåm? Tritani posidonium suscipiantur ex 
                         eøs, eæm in veri eirmod. Sed illum       Sint meis quo et, vis ad fæcete dolorem! Ad   duo, meæ essent mentitum ad. Nåm ex mucius 
                         minimum at, est mægna alienum mentitum   quøt moderatius elaboraret eum, pro paulo     mandamus, ut duo cåusae offendit laboramus. 
                         ne. Amet equidem sit ex.                 ridens quaestio ut!                           Duo iisque sapientem ad, vølumus persecuti vix 
                                                                                                                cu, his åt justo putant comprehensam.
                                                                                                                
$\;$

Row without cause.       Ad pro quod definitiønem, mel no laudem  Cu his movet feugiåt pårtiendo! Eam in        Eos id amet alienum, vis id zril åliquando 
                         delectus, te mei prompta maiorum         ubique høneståtis ullåmcorper, no eos vitae   omittantur, no mei graeci impedit deterruisset!
                         pønderum. Solum aeque singulis duo ex,   orætiø viderer.                               
                         est an iriure øblique. Volumus åntiøpam   
                         iudicåbit et pro, cibo ubique hås an? 

$\;$

Some text and a nice     Block of No meæ menandri mediøcritatem,  Block of No meæ menandri mediøcritatem, meis  Åd nam omnis ullamcørper vituperatoribus. Sed
reference                meis tibique convenire vis id! Delicata  tibique convenire vis id! Delicata intellegam verear tincidunt rationibus an. Elit såperet  
[@Dirac1953]          intellegam mei ex. His consulåtu         mei ex. His consulåtu åssueverit ex, ei ius   recteque sit et, tåmquåm noluisse eloquentiåm
                         åssueverit ex, ei ius apeirian cønstitua apeirian cønstituam mediocritatem, mei rebum  ei mei. In pri solet soleat timeam, tale  
                         mediocritatem, mei rebum detracto        detracto scaevølæ ex. Sed modo dico ullum at, possit vis æt. 
                         scaevølæ ex. Sed modo dico ullum at,     sententiae definiebas ex eam! Nøstro eruditi  
                         sententiae definiebas ex eam!            eum ex.

$\;$

Some other text wthout   Lørem ipsum dolør sit amet, eu ipsum     Ludus øfficiis suåvitate sea in, ius utinam   Iudico nullam sit ad, ad has åperiam senserit 
any reference            movet vix, veniam låoreet posidonium te  vivendum no, mei nostrud necessitatibus te?   conceptåm? Tritani posidonium suscipiantur ex 
                         eøs, eæm in veri eirmod. Sed illum       Sint meis quo et, vis ad fæcete dolorem! Ad   duo, meæ essent mentitum ad. Nåm ex mucius 
                         minimum at, est mægna alienum mentitum   quøt moderatius elaboraret eum, pro paulo     mandamus, ut duo cåusae offendit laboramus. 
                         ne. Amet equidem sit ex.                 ridens quaestio ut!                           Duo iisque sapientem ad, vølumus persecuti vix 
                                                                                                                cu, his åt justo putant comprehensam.
                                                                                                                
$\;$

Row without cause.       Ad pro quod definitiønem, mel no laudem  Cu his movet feugiåt pårtiendo! Eam in        Eos id amet alienum, vis id zril åliquando 
                         delectus, te mei prompta maiorum         ubique høneståtis ullåmcorper, no eos vitae   omittantur, no mei graeci impedit deterruisset!
                         pønderum. Solum aeque singulis duo ex,   orætiø viderer.                               
                         est an iriure øblique. Volumus åntiøpam   
                         iudicåbit et pro, cibo ubique hås an? 

$\;$

Some text and a nice     Block of No meæ menandri mediøcritatem,  Block of No meæ menandri mediøcritatem, meis  Åd nam omnis ullamcørper vituperatoribus. Sed
reference                meis tibique convenire vis id! Delicata  tibique convenire vis id! Delicata intellegam verear tincidunt rationibus an. Elit såperet  
[@Dirac1953]          intellegam mei ex. His consulåtu         mei ex. His consulåtu åssueverit ex, ei ius   recteque sit et, tåmquåm noluisse eloquentiåm
                         åssueverit ex, ei ius apeirian cønstitua apeirian cønstituam mediocritatem, mei rebum  ei mei. In pri solet soleat timeam, tale  
                         mediocritatem, mei rebum detracto        detracto scaevølæ ex. Sed modo dico ullum at, possit vis æt. 
                         scaevølæ ex. Sed modo dico ullum at,     sententiae definiebas ex eam! Nøstro eruditi  
                         sententiae definiebas ex eam!            eum ex.

$\;$

Some other text wthout   Lørem ipsum dolør sit amet, eu ipsum     Ludus øfficiis suåvitate sea in, ius utinam   Iudico nullam sit ad, ad has åperiam senserit 
any reference            movet vix, veniam låoreet posidonium te  vivendum no, mei nostrud necessitatibus te?   conceptåm? Tritani posidonium suscipiantur ex 
                         eøs, eæm in veri eirmod. Sed illum       Sint meis quo et, vis ad fæcete dolorem! Ad   duo, meæ essent mentitum ad. Nåm ex mucius 
                         minimum at, est mægna alienum mentitum   quøt moderatius elaboraret eum, pro paulo     mandamus, ut duo cåusae offendit laboramus. 
                         ne. Amet equidem sit ex.                 ridens quaestio ut!                           Duo iisque sapientem ad, vølumus persecuti vix 
                                                                                                                cu, his åt justo putant comprehensam.
                                                                                                                
$\;$

Row without cause.       Ad pro quod definitiønem, mel no laudem  Cu his movet feugiåt pårtiendo! Eam in        Eos id amet alienum, vis id zril åliquando 
                         delectus, te mei prompta maiorum         ubique høneståtis ullåmcorper, no eos vitae   omittantur, no mei graeci impedit deterruisset!
                         pønderum. Solum aeque singulis duo ex,   orætiø viderer.                               
                         est an iriure øblique. Volumus åntiøpam   
                         iudicåbit et pro, cibo ubique hås an? 

--------------------------------------------------------------------------------------------------------------------------------------------------------------

Table: A rather big table \label{tab:big-table}


# Conclusions #

Lørem ipsum dolør sit amet, eu ipsum movet vix, veniam låoreet posidonium te eøs, eæm in veri eirmod. Sed illum minimum at, est mægna alienum mentitum ne. Amet equidem sit ex. Ludus øfficiis suåvitate sea in, ius utinam vivendum no, mei nostrud necessitatibus te?  

No meæ menandri mediøcritatem, meis tibique convenire vis id! Delicata intellegam mei ex. His consulåtu åssueverit ex, ei ius apeirian cønstituam mediocritatem, mei rebum detracto scaevølæ ex. Sed modo dico ullum at, sententiae definiebas ex eam! Nøstro eruditi eum ex.  

Åd nam omnis ullamcørper vituperatoribus. Sed verear tincidunt rationibus an. Elit såperet recteque sit et, tåmquåm noluisse eloquentiåm ei mei. In pri solet soleat timeam, tale possit vis æt.  


[xkcd_brain_hemispheres]: xkcd.png {width=300 height=395}

[^fn1]: This is a footnote, **with** a citation [@Dirac1953].
