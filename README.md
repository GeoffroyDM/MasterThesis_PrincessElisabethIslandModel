# MasterThesis_PrincessElisabethIslandModel
This repository contains the MATLAB Simulink files in which a model of the Princess Elisabeth Island is implemented. This model is produced for the master thesis Dynamic Modelling and Control of a Hybrid Link in the Context of an Energy Island.

param.m contains the parameters of the wind turbine and the hvdc link and should be run before running the slx files. 
The parameter n_wt_agg set the number of wind turbines in the aggregated model.
n_wt_agg = 1 models the 2 MW wind turbine, while n_wt_agg = 150 models the 300 MW equivalent wind turbine.

Wind_Turbine_Model contains the wind turbine model.

Complete_Model contains the complete model of the Princess Elisabeth Island system.
