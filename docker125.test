FROM ranktotop/cudadocker:125_nvenc

######################################
###### INSTALL SYSTEM PACKAGES #######
######################################
RUN apt-get update \
    && apt-get install -y ffmpeg\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

######################################
########### COPY SCRIPTS #############
######################################
COPY testskript125.sh /home/appuser/gputest/testskript.sh
COPY testskript125.py /home/appuser/gputest/testskript.py
RUN chmod +x /home/appuser/gputest/testskript.sh

#crate logs folder
RUN mkdir /home/appuser/gputest/logs
RUN touch /home/appuser/gputest/logs/app.log

# Keep the container running
CMD ["sleep", "infinity"]