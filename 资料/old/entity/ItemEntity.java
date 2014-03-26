package com.mirror.insuranceassistant.entity;

public class ItemEntity {
	
	private String title;
	private ContactsAddPinYin contactsAddPinYin;

	public ItemEntity(String title, ContactsAddPinYin contactsAddPinYin) {
		this.title = title;
		this.contactsAddPinYin = contactsAddPinYin;
	}
	
	public String getTitle() {
		return title;
	}

	public ContactsAddPinYin getContactsAddPinYin() {
		return contactsAddPinYin;
	}

	@Override
	public String toString() {
		return "ItemEntity [title=" + title + ", contactsAddPinYin=" + contactsAddPinYin + "]";
	}
}
