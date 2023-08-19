FROM nvidia/cuda:11.8.0-devel-ubuntu20.04
# 设置工作目录
WORKDIR /app

# 复制必要的文件
COPY ./FastChat/fastchat /app/fastchat
COPY ./pyllama2_data/7B_instruct_8-1_hf /app/pyllama2_data/7B_instruct_8-1_hf
COPY requirements.txt /app/
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 更新软件包列表并安装 wget 和其他必要的工具
RUN apt-get update && apt-get install -y wget git build-essential

# 安装 Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

# 设置环境变量
ENV PATH /opt/conda/bin:$PATH

# 使用 conda 安装 Python 依赖
RUN conda create -n fc3 python=3.10 && \
    echo "source activate fc3" > ~/.bashrc && \
    /opt/conda/envs/fc3/bin/pip install -r requirements.txt

# 从源代码编译 bitsandbytes
RUN git clone https://github.com/TimDettmers/bitsandbytes.git && \
    cd bitsandbytes && \
    CUDA_VERSION=118 make cuda11x && \
    /opt/conda/envs/fc3/bin/python setup.py install

# 设置环境变量以使用 CUDA
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:$LD_LIBRARY_PATH
