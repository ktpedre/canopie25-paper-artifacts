# canopie25-paper-artifacts

This repo contains example run scripts and gnuplot files needed to reproduce results in the following paper:

```
@inproceedings{beltre2025,
  author    = {Angel M. Beltre and Jeff Ogden and Kevin Pedretti},
  title     = {{Experience Deploying Containerized GenAI Services at an HPC Center}},
  booktitle = {7th International Workshop on Containers and New Orchestration Paradigms for Isolated Environments in HPC (CANOPIE-HPC), held in conjunction with SC25},
  month     = {November},
  year      = {2025},
  doi       = {10.1145/3731599.3767356}
}
```

If you find these examples valuable and adapt them for your use in your own
work, we would appreciate you citing the above paper.

The HPC workflow for deploying vLLM and benchmarking it is located in the
"hpc-workflow" directory. The steps of the workflow are named in order,
starting with "0-alloc-compute-node.sh" and ending at "5-run-benchmark.sh".
Example output for each step is provided in the hpc-workflow/example-output
directory.

The Kubernetes / OpenShift workflow for deploying vLLM is located in the
"k8s-workflow" directory.  Note that the Helm Chart in the
k8s-workflow/helm-chart directory is derived from the upstream vLLM project
(See "k8s-workflow/helm-chart/README-CANOPIE25.md" for details).

Gnuplot scripts for ploting results in the paper are located in the "plots" directory.
