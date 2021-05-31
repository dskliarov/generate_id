# IdGenerator

## Short solution description

Requirement: 
 Generate Id with following characteristics

 - ID must be globally unique
 - ID is a 64-bit integer
 Less than 100k requests per second

The obvious solution would be to use the combination of node_id, Unix time  and sequence number.
Unix time is in milliseconds, which require to have a sequence number of size 7 (up to 127 value)
The max number of nodes is 1024, which requires allocating 10 bytes for it.

So the globally unique number, which not require internode integration and not require persistence, which increase availablility, whould be

 <<node_id::unsigned-integer-size(10), timestamp::unsigned-integer-64, sequence_number::unsigned-integer-size(7)>>

The size of ID will be greater than 64, which does not satisfy our requirements.
 
It dictates finding another solution. 
We can't use unix_timestamp as it is, because of the size limitation, so we have to find another solution.
 
Unfortunately, we can't avoid the persistence of metadata, which adds a dependency to our solution.
 
The solution is going to be deployed to the K8s, which adds the limitation on persistence volume and Erlang cluster forming. The ID will have 2 components: epoch and sequence number.
Every time node starts, epoch number will be increased by one and every request sequence number will be increased by one. The ID structure is:  

 <<epoch::unsigned-integer-size(47), counter::unsigned-integer-size(17)>>
 
For epoch number coordination, the solution will use the Redis counter, but other tools are available. Then bigger the size of the counter, then less frequently counter must be increased, which decrease Redis load.
 
An alternative solution would be to use ETCD DB which allows using the counter watch, which will improve counter increasing transaction latency.
 
To improve the throughput of the node, we can add multiple workers and use a pooler with it.
 
To load test the solution, a Proper library would be a good solution (Time limitation does not allow to have the example of it).
