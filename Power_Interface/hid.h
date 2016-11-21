
extern int rawhid_open(int max, int vid, int pid, int usage_page, int usage);
extern int rawhid_recv(int num, void *buf, int len, int timeout);
extern int rawhid_send(int num, void *buf, int len, int timeout);
extern void rawhid_close(int num);
extern int rawhid_status(void);
extern int usb_present(void);
extern const char* get_manu(void);
extern const char* get_prod(void);
extern int getX();

extern const int BufferSize(void);
