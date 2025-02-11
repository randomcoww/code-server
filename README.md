#### Container for code-server (VS Code in a browser)

https://github.com/coder/code-server

Runs under S6 overlay init to allow process cleanup

#### Tensorflow setup

```bash
conda create --name tf -c conda-forge python=3.12
conda activate tf

pip install --upgrade pip setuptools wheel
pip install --upgrade tensorflow[and-cuda]
pip install tensorrt==8.6.1

export CUDNN_PATH=$(dirname $(python -c "import nvidia.cudnn;print(nvidia.cudnn.__file__)"))
export TENSORRT_PATH=$(dirname $(python -c "import tensorrt;print(tensorrt.__file__)"))
TENSORRT_VERSION=$(python -c "import tensorrt;print(tensorrt.__version__)")

pushd ${TENSORRT_PATH}_libs
ln -sf libnvinfer.so.8 libnvinfer.so.$TENSORRT_VERSION
ln -sf libnvinfer_plugin.so.8 libnvinfer_plugin.so.$TENSORRT_VERSION
popd

export LD_LIBRARY_PATH=$CONDA_PREFIX/lib/:${TENSORRT_PATH}_libs/:$CUDNN_PATH/lib/:$LD_LIBRARY_PATH
```

```python
import tensorflow as tf
print(tf.config.list_physical_devices('GPU'))
```
