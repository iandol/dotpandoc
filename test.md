---
title: Test Workflow with Crossref
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
    email: john@doe.org
    orcid: 0000-0012-3456-789X
institute:
  - 1: University of XYZ
  - 2: Institute of ZYX
abstract: This is the abstract for a test file. Lørem ipsum dolør sit amet, eu ipsum movet vix, veniam låoreet posidonium te eøs, eæm in veri eirmod. Sed illum minimum at, est mægna alienum mentitum ne.
keywords: [pandoc, pandocomatic]
date: 1^st^ January 2025
toc: true
pandocomatic_:
  use-template: [latex-crossref]
  pandoc:
    bibliography: ./test.bib # The name of the test bib-file.
---

# 1. Intro #

Lørem ipsum dolør sit amet, eu ipsum movet vix [@Dirac1953;@Feynman1963], veniam låoreet posidonium te eøs, eæm in veri eirmod. Sed illum minimum at, est mægna alienum mentitum ne (please see @fig:labelone). Amet equidem sit ex (@eq:label). Ludus øfficiis suåvitate sea in, ius utinam vivendum no, mei nostrud necessitatibus te?  

![This is a fascinating caption (source and explanation: [XKCD](https://www.explainxkcd.com/wiki/index.php/2120:_Brain_Hemispheres))](xkcd.png){#fig:labelone width=200 height=295}

Sint meis quo et [@Schrodinger1926], vis ad fæcete dolorem[^fn1]! Ad quøt moderatius elaboraret eum, pro paulo ridens quaestio ut! Iudico nullam sit ad, ad has åperiam senserit conceptåm? Tritani posidonium suscipiantur ex duo, meæ essent mentitum ad. Nåm ex mucius mandamus, ut duo cåusae offendit laboramus. Duo iisque sapientem ad, vølumus persecuti vix cu, his åt justo putant comprehensam.  

$$ V = \int_0^\infty  {{N_t}u({c_t})\,{e^{ - \delta t}}dt} $$ {#eq:label}

Ad pro quod definitiønem (see @fig:labeltwo), mel no laudem delectus, te mei prompta maiorum pønderum. Solum aeque singulis duo ex, est an iriure øblique. Volumus åntiøpam iudicåbit et pro, cibo ubique hås an? Cu his movet feugiåt pårtiendo! Eam in ubique høneståtis ullåmcorper, no eos vitae orætiø viderer. Eos id amet alienum, vis id zril åliquando omittantur, no mei graeci impedit deterruisset!  

![This is another Caption.](xkcd.png){#fig:labeltwo}

No meæ menandri mediøcritatem, meis tibique convenire vis id! Delicata intellegam mei ex. His consulåtu åssueverit ex, ei ius apeirian cønstituam mediocritatem, mei rebum detracto scaevølæ ex. Sed modo dico ullum at, sententiae definiebas ex eam! Nøstro eruditi eum ex.  

Åd nam omnis ullamcørper vituperatoribus. Sed verear tincidunt rationibus an. Elit såperet recteque sit et, tåmquåm noluisse eloquentiåm ei mei. In pri solet soleat timeam, tale possit vis æt.  


# 2. Details #

Lørem ipsum dolør sit amet, eu ipsum movet vix, veniam låoreet posidonium te eøs, eæm in veri eirmod. Sed illum minimum at, est mægna alienum mentitum ne. Amet equidem sit ex. Ludus øfficiis suåvitate sea in, ius utinam vivendum no, mei nostrud necessitatibus te?  

Sint meis quo et, vis ad fæcete dolorem! Ad quøt moderatius elaboraret eum, pro paulo ridens quaestio ut! Iudico nullam sit ad, ad has åperiam senserit conceptåm? Tritani posidonium suscipiantur ex duo, meæ essent mentitum ad. Nåm ex mucius mandamus, ut duo cåusae offendit laboramus. Duo iisque sapientem ad, vølumus persecuti vix cu, his åt justo putant comprehensam.  
Ad pro quod definitiønem, mel no laudem delectus, te mei prompta maiorum pønderum. Solum aeque singulis duo ex, est an iriure øblique. Volumus åntiøpam iudicåbit et pro, cibo ubique hås an? Cu his movet feugiåt pårtiendo! Eam in ubique høneståtis ullåmcorper, no eos vitae orætiø viderer. Eos id amet alienum, vis id zril åliquando omittantur, no mei graeci impedit deterruisset!  

## 2.1 Sun ##

No meæ menandri mediøcritatem, meis tibique convenire vis id! Delicata intellegam mei ex. His consulåtu åssueverit ex, ei ius apeirian cønstituam mediocritatem, mei rebum detracto scaevølæ ex. Sed modo dico ullum at, sententiae definiebas ex eam! Nøstro eruditi eum ex.  

### 2.1.1 Solar Flare 1 ###

No meæ menandri mediøcritatem, meis tibique convenire vis id! Delicata intellegam mei ex. His consulåtu åssueverit ex, ei ius apeirian cønstituam mediocritatem, mei rebum detracto scaevølæ ex. Sed modo dico ullum at, sententiae definiebas ex eam! Nøstro eruditi eum ex.  

### 2.1.2 Solar Flare 2 ###

No meæ menandri mediøcritatem, meis tibique convenire vis id! Delicata intellegam mei ex. His consulåtu åssueverit ex, ei ius apeirian cønstituam mediocritatem, mei rebum detracto scaevølæ ex. Sed modo dico ullum at, sententiae definiebas ex eam! Nøstro eruditi eum ex.  

## 2.2 Moon ##

No meæ menandri mediøcritatem, meis tibique convenire vis id! Delicata intellegam mei ex. His consulåtu åssueverit ex, ei ius apeirian cønstituam mediocritatem, mei rebum detracto scaevølæ ex. Sed modo dico ullum at, sententiae definiebas ex eam! Nøstro eruditi eum ex.  

Åd nam omnis ullamcørper vituperatoribus. Sed verear tincidunt rationibus an. Elit såperet recteque sit et, tåmquåm noluisse eloquentiåm ei mei. In pri solet soleat timeam, tale possit vis æt.  

# 3. Conclusions #

Lørem ipsum dolør sit amet, eu ipsum movet vix, veniam låoreet posidonium te eøs, eæm in veri eirmod. Sed illum minimum at, est mægna alienum mentitum ne. Amet equidem sit ex. Ludus øfficiis suåvitate sea in, ius utinam vivendum no, mei nostrud necessitatibus te?  

No meæ menandri mediøcritatem, meis tibique convenire vis id! Delicata intellegam mei ex. His consulåtu åssueverit ex, ei ius apeirian cønstituam mediocritatem, mei rebum detracto scaevølæ ex. Sed modo dico ullum at, sententiae definiebas ex eam! Nøstro eruditi eum ex.  

Åd nam omnis ullamcørper vituperatoribus. Sed verear tincidunt rationibus an. Elit såperet recteque sit et, tåmquåm noluisse eloquentiåm ei mei. In pri solet soleat timeam, tale possit vis æt.  


[xkcd_brain_hemispheres]: xkcd.png {width=200 height=295}

[^fn1]: This is a footnote, **with** a citation [@Dirac1953].
