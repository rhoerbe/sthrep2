************************************************************************
SAML Test Harness Repository - A tool to manage SAML profile test planes
************************************************************************

:Author: Rainer Hörbe
:Version: 0.3.0


Scope and Purpose
=================
Assure compliance of federation-facing interfaces of SAML actors

The SAML Test Harness is a tool for deployers to assess their products and services for interoperability and compliance with a specific SAML deployment profile.

The Framework is designed as a community service that shall be provided as a kind of cloud service with a common repository of operations. Testers can contribute to the repository thus resembling a crowd-sourced approach to testing.


The repository creates test configurations to be use with the test driver developted in the SAML2test project also on githup.

Key Components
==============

Repository Manager
::::::::::::::::::
It stores and organizes test plans that are maintained by Test Designers and used by the Test Operators to execute tests.
* Test Designers define and extend operations for Test Plans. The repository shall provide a structure to maximize reuse of operations.
* Test Operators shall be provided with ready-to-use Test Plans, which they just need to augment with deployment-specific configuration parameters to make them ready for execution.
* Test plans and their components have versions. A test plan with a specific version is stable, and changes will be applied to future versions.
* The Repository shall be a common resource for many deployments. Test cases should be shared and improved in a community effort, allowing for their use with different SAML profiles, Test Plans and test targets. To support such a model, a service-type operation repository is being proposed as a single instance for all interested stakeholders.
* The interface to the Test Driver is an export of python classes and utilizes the pySAML2 library.

Ideally, the repository should contain a superset of all operations for all deployments to be tested providing reasonable test coverage. Operations can be grouped and parameterized to address certain test scenarios. An extension and inheritance schema could be used to organize multiple scenarios.

Test execution would be the task of deployment-specific infrastructure. The tester would configure the test data and execute the tests. There should be no need to install local instances of the test framework.

 
Test GUI
::::::::
This is a GUI application to configure, execute and analyze tests:
-	Parameterization of tests plans with deployment specific parameters, (like metadata, selected entities)
-	Recording of user interactions like login or IDP-discovery to create interaction commands
-	Prettify test results.

Test Driver
:::::::::::
The Test Driver (see project SAML2test) is being invoked via command line or Test GUI for a specific operation in a specified test configuration. It emulates a communication partner to the Test Target. E.g. if the Test Target is an IdP, the Test Driver emulates a web browser with a user and a SP.
Each operation comprises 3 groups:
#	Pre-interaction check
#	Interaction
#	Post-interaction check
Each group is implemented as a sequence of python classes.
A simple operation in this context would be for example "Send signed authentication request via redirect binding and expect a signed response with persistent NameID and a certain bundle of attributes". Some other operations are:
*	AuthnRequest using HTTP POST expecting transient NameID
*	AuthnRequest and then an AuthnQuery
*	SAML2 AuthnRequest using ECP and PAOS
*	AuthnRequest using HTTP-redirect followed by a logout


