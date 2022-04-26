FROM amazoncorretto:11

# PySpark requires Python
RUN yum -y update && yum -y install python3 python3-pip hostname

# Install some custom libraries
RUN python3 -m pip --no-cache-dir install -U numpy

ENV PYSPARK_DRIVER_PYTHON python3
ENV PYSPARK_PYTHON python3
