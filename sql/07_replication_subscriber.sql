-- Subscribe to the publisher's t1_pub publication.
-- conn_string is passed in from subscriber-init.sh

CREATE SUBSCRIPTION t1_sub
    CONNECTION :'conn_string'
    PUBLICATION t1_pub;
