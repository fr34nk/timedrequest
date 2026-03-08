# timedrequest

### What this tool is for:

This tool propose an easy method to add timestamp validation to things you think 
you need to prove to someone that happened at time you execute the commands. 

For example, imagine you received a file and somehow want a proof the file was exactly
as you received in a moment in future. Just execute `tsr_from_file` and you get a proof
(`tsr file`) of the exact content of the file in the moment you executed the command. 
If someone in the future contest you about the file you received correspond to the 
version he has, just send him the `tsr file`.

It is useful for persons that need a proof of existence of files, either to check their 
integrity, or to send to someone else proof of it.

The main functionalities are in the `request` and `tsr_and_txt_from_file` functions.

`request <url>` will execute a curl request to <url> and give you all files that prove
the content of the returned html page in that point time;

`tsr_and_txt_from_file <file>` will execute the same process, but from a file you already have
in your disk. Just execute it and will get the same output of the request, the files that
prove the existence of that "content" in a point time;


### How to use

In a bash terminal execute:

```bash
source request.sh # it will add to your bash session
```

then:

```bash
request <url>
tsr_and_txt_from_file <url>
```

### Main Features:

- [ ] Create cross platform support
- [ ] Create a gui version of it
- [ ] Create support to different hash algorithm
- [x] Request data for user
- [x] Record the time of existence record parallel to the request of data
- [x] Use different servers for time of existence record
- [ ] Implement different ways of querying the data itself
- [ ] Implement queue system to classify the server response,
- [ ] Implement redundancy on time record request
- [ ] Support to proxy configuration, both for the request as for the time query record


### Technical Tasks

- [ ] Parametrize env variables into the options arguments to the main request function



