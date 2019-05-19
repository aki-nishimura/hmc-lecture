
# Lecture on Hamiltonian Monte Carlo: theory and practice
Beamer slides with emphasis on the theoretical aspects of Hamiltonian Monte Carlo (HMC) most relevant to its practical performances. The lecture is geared towards the audience who wishes to either 1) get best performances out of HMC-based Bayesian inference softwares (a bit of prior experience would be helpful) or 2) incorporate HMC and its variants into their custom Markov chain Monte Carlo implementations. The covered topics and provided references should be comprehensive enough that the lecture also provides a solid foundation for further exploring the subject of HMC and its extensions.

The contents in these slides are meant to complement the existing HMC tutorials (though there naturally are substantial overlaps). To list a few notable features, the slides cover the topics such as
* analysis of HMC performance on multivariate Gaussians (with the closed-form expressions on the numerically approximated dynamics and average Hamiltonian error).
* HMC's sensitivity on the tail-behavior of a target distribution and how it impacts the choice of the integrator stepsize.
* pointers to the up-to-date (as of May, 2019) theory, methodology, and practices of HMC and related algorithms.

## Notes on the source files.
Near the top of the TeX file, you find boolean flags that can be used to include or exclude some contents.
