# Documentation

Comprehensive documentation for the HunyuanVideo-I2V deployment on Grace-Hopper HPC.

---

## 📖 Quick Navigation

### For New Users
- **[QUICKSTART.md](QUICKSTART.md)** - Get started in 3 steps (45 minutes)
  - Setup environment
  - Install flash-attention
  - Launch jobs

### For Troubleshooting
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions
  - Flash-attention compilation errors
  - Module loading issues
  - Job failures
  - AWS S3 problems

### For Technical Context
- **[AGENT_HISTORY.md](AGENT_HISTORY.md)** - Complete deployment history
  - Detailed technical decisions
  - ARM64 adaptation strategies
  - All challenges and solutions
  - Performance benchmarks

### For Management
- **[DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md)** - Executive summary
  - Key achievements
  - Performance metrics
  - Resource utilization
  - Success criteria

---

## 📁 Additional Documentation

### Project Root
- **[../README.md](../README.md)** - Main project overview and quick start

### SLURM Setup
- **[../slurm/README.md](../slurm/README.md)** - SLURM job management overview
- **[../slurm/REORGANIZATION_SUMMARY.md](../slurm/REORGANIZATION_SUMMARY.md)** - SLURM reorganization details

### Model-Specific
- **[../slurm/hunyuan-video-i2v/docs/SETUP_GUIDE.md](../slurm/hunyuan-video-i2v/docs/SETUP_GUIDE.md)** - HunyuanVideo setup guide
- **[../slurm/hunyuan-video-i2v/docs/FLASH_ATTENTION.md](../slurm/hunyuan-video-i2v/docs/FLASH_ATTENTION.md)** - Flash-attention installation details

---

## 🎯 Documentation Purpose

### QUICKSTART.md
**Audience**: New users  
**Goal**: Get the system running in 45 minutes  
**Content**:
- Step-by-step setup instructions
- Expected outputs at each stage
- Quick verification commands
- Common issues and fixes

### TROUBLESHOOTING.md
**Audience**: All users experiencing issues  
**Goal**: Self-service problem resolution  
**Content**:
- Categorized by problem type
- Symptoms → Cause → Solution format
- Verification commands
- Emergency procedures

### AGENT_HISTORY.md
**Audience**: Developers, system administrators  
**Goal**: Complete technical understanding  
**Content**:
- Chronological deployment history
- Technical decisions and rationale
- ARM64-specific adaptations
- Detailed troubleshooting examples
- Performance analysis

### DEPLOYMENT_SUMMARY.md
**Audience**: Management, stakeholders  
**Goal**: High-level project overview  
**Content**:
- Key achievements
- Success metrics
- Resource requirements
- Future enhancements
- Handoff information

---

## 🔄 Documentation Workflow

### For Users Getting Started
1. Read [QUICKSTART.md](QUICKSTART.md)
2. If you hit issues → Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
3. Still stuck → Review relevant section in [AGENT_HISTORY.md](AGENT_HISTORY.md)

### For System Understanding
1. Start with [DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md) for overview
2. Deep dive into [AGENT_HISTORY.md](AGENT_HISTORY.md) for technical details
3. Reference [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for specific issues

---

## 📊 Document Statistics

| Document | Lines | Focus | Audience |
|----------|-------|-------|----------|
| QUICKSTART.md | ~200 | Practical | New users |
| TROUBLESHOOTING.md | ~600 | Problem-solving | All users |
| AGENT_HISTORY.md | ~670 | Technical depth | Developers |
| DEPLOYMENT_SUMMARY.md | ~390 | Overview | Management |

---

## 🔧 Maintenance

### Updating Documentation

When making changes to the system:

1. **Setup changes** → Update QUICKSTART.md and AGENT_HISTORY.md
2. **New issues** → Add to TROUBLESHOOTING.md
3. **Performance changes** → Update DEPLOYMENT_SUMMARY.md
4. **File moves** → Update all cross-references

### Cross-Reference Guidelines

- Use relative paths for links
- Verify links after any reorganization
- Include file paths in code examples
- Update README.md when adding new docs

---

## ✅ Documentation Coverage

### Covered Topics
- ✅ Initial setup and configuration
- ✅ Flash-attention compilation on ARM64
- ✅ Dependency resolution for ARM64/Python 3.12
- ✅ SLURM job submission and monitoring
- ✅ AWS S3 integration
- ✅ Performance optimization
- ✅ Troubleshooting common issues
- ✅ HPC module system configuration

### Future Documentation Needs
- Multi-GPU setup with xDiT
- Container packaging (Docker/Singularity)
- Automated testing procedures
- Performance benchmarking methodology

---

**Last Updated**: January 13, 2026  
**Status**: ✅ Complete and current
