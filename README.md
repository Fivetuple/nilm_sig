
#
# Supporting code for PES conference paper, "Automatic feature generation for non-intrusive load monitoring using path signatures."
#
# PJM 23-APR-21


---------------------------------------------------------------------------------------------------------
# results scripts


predict_reference_features.m                                - Replication - predict reference features from signature.

predict_cooll_labels_using_reference_features.m             - Predict COOLL labels using reference features.

trainEnsemble.m                                             - Output from classification app, amended.

trainKNN.m                                                  - Output from classification app, amended.

trainSVM.m                                                  - Output from classification app, amended.

reference_predictor_importance.m                            - Predictor importance analysis for reference features.

predict_cooll_labels_using_signatures.m                     - Predict COOLL labels using path signatures.

signature_predictor_importance.m                            - Predictor importance analysis for log signatures.

predict_cooll_labels_using_selected_reference_features.m    - Replication - prediction using 5 features.

trainEnsembleSelected.m                                     - trainEnsemble model for 5 features.

predict_cooll_labels_using_selected_signatures.m            - Prediction using 7 signature features.

trainEnsembleSignatureSelected.m                            - trainEnsemble model for 7 features.


---------------------------------------------------------------------------------------------------------
# data creation scripts

save_reference_features.m                                   - Generate and save Bruna Mulinari's proposed features.

save_signatures.m                                           - Generate and save path signatures of trajectories.

---------------------------------------------------------------------------------------------------------
# auxilliary scripts

next_upward_zero_crossing.m                                 - Returns the index of the next upward zero crossing in the vector.

errperf.m                                                   - Error metrics (amended from original).

errperf_license.txt                                         - Licence file for errperf.

esig_shell.py                                               - Python signature script.

matlab_esig_shell.m                                         - MATLAB signature script.

---------------------------------------------------------------------------------------------------------
# directories

data                                                        - Data folder holding labels.txt, cooll_on_off_times.mat, and generated features.

V-I_trajectory                                              - From https://github.com/brunamulinari/V-I_trajectory

---------------------------------------------------------------------------------------------------------

Additional data and code needed if recreating features:


1. COOLL data - https://coolldataset.github.io/.  

2. https://github.com/brunamulinari/V-I_trajectory.      

3. Python esig package - https://pypi.org/project/esig/. 


The training labels (./Data/labels.txt) are found from the Cool Config files  (cooll/Configs/scenario1_*.txt)
using, 

grep Outlet1 * > ./labels_raw.txt

and from it generating labels.txt using a text editor.  A first try with this approach generated some labels 
"Vacuum_cleaner_" owing to a space at the end of the line.  These labels were corrected with a global search and replace.



