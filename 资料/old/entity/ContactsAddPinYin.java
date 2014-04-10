package com.mirror.insuranceassistant.entity;

public class ContactsAddPinYin implements Comparable<ContactsAddPinYin>{

	private CP_Contacts cpContacts;
	private String pinYinName;

	public ContactsAddPinYin() {

	}

	public ContactsAddPinYin(CP_Contacts cpContacts, String pinYinName) {
		this.cpContacts = cpContacts;
		this.pinYinName = pinYinName;
	}

	public CP_Contacts getCpContacts() {
		return cpContacts;
	}

	public void setCpContacts(CP_Contacts cpContacts) {
		this.cpContacts = cpContacts;
	}

	public String getPinYinName() {
		return pinYinName;
	}

	public void setPinYinName(String pinYinName) {
		this.pinYinName = pinYinName;
	}

	@Override
	public int compareTo(ContactsAddPinYin another) {
		return this.getPinYinName().compareTo(another.getPinYinName());
	}

}
